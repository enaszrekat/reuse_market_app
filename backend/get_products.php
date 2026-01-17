<?php
/**
 * Get all approved products
 * Returns JSON with products including images
 * FIXED: Uses PDO like get_user_products.php (which works)
 */

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ✅ CRITICAL: Disable error display to prevent HTML in JSON output
error_reporting(0);
ini_set('display_errors', 0);

// Database configuration - EXACT SAME as get_user_products.php
$host = "localhost";
$dbname = "market_app";
$username = "root";
$password = "";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed"
    ]);
    exit();
}

try {
    // ✅ EXACT SAME QUERY STRUCTURE as get_user_products.php
    $sql = "SELECT 
                p.id,
                p.title,
                p.description,
                p.price,
                p.type,
                p.status,
                p.user_id,
                p.created_at,
                u.name AS owner_name,
                u.username AS owner_username,
                GROUP_CONCAT(COALESCE(pi.image_path, pi.image_name) ORDER BY pi.id SEPARATOR ',') as images
            FROM products p
            LEFT JOIN users u ON p.user_id = u.id
            LEFT JOIN product_images pi ON p.id = pi.product_id
            WHERE p.status = 'approved'
            GROUP BY p.id
            ORDER BY p.created_at DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    
    $products = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        // ✅ EXACT SAME LOGIC as get_user_products.php (lines 71-75)
        $images = [];
        if (!empty($row['images'])) {
            $images = explode(',', $row['images']);
            $images = array_filter($images); // Remove empty values
            $images = array_values($images); // Re-index array
        }
        
        $products[] = [
            "id" => intval($row['id']),
            "title" => $row['title'] ?? "",
            "description" => $row['description'] ?? "",
            "price" => floatval($row['price'] ?? 0),
            "type" => $row['type'] ?? "sell",
            "status" => $row['status'] ?? "pending",
            "user_id" => intval($row['user_id'] ?? 0),
            "created_at" => $row['created_at'] ?? "",
            "owner_name" => $row['owner_name'] ?? null,
            "owner_username" => $row['owner_username'] ?? null,
            "images" => $images, // Always an array (same format as get_user_products.php)
            "image" => !empty($images) ? $images[0] : null // For backward compatibility
        ];
    }
    
    echo json_encode([
        "status" => "success",
        "products" => $products
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Database query failed"
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Server error occurred"
    ]);
}
?>
