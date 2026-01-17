<?php
/**
 * Get products for a specific user
 * Returns JSON with user's APPROVED products including images
 * FIXED: Only returns approved products
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

error_reporting(0);
ini_set('display_errors', 0);

// Database configuration
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
    // Get user_id from POST request
    $user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
    
    if ($user_id <= 0) {
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "Invalid user_id"
        ]);
        exit();
    }

    // ✅ Query to get user's APPROVED products with images
    $sql = "SELECT 
                p.id,
                p.title,
                p.description,
                p.price,
                p.type,
                p.status,
                p.created_at,
                GROUP_CONCAT(COALESCE(pi.image_path, pi.image_name) ORDER BY pi.id SEPARATOR ',') as images
            FROM products p
            LEFT JOIN product_images pi ON p.id = pi.product_id
            WHERE p.user_id = :user_id
            AND p.status = 'approved'
            GROUP BY p.id
            ORDER BY p.created_at DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $stmt->execute();
    
    $products = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        // Convert images string to array
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
            "status" => $row['status'] ?? "approved",
            "created_at" => $row['created_at'] ?? "",
            "images" => $images,
            // For backward compatibility, also include first image as "image"
            "image" => !empty($images) ? $images[0] : null
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
        "message" => "An error occurred: " . $e->getMessage()
    ]);
}
?>
