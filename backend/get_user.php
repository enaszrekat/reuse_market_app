<?php
/**
 * Get user information by user_id
 * Returns JSON with user data
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

// Database configuration
$host = "localhost";
$dbname = "market_app"; // Change to your database name
$username = "root"; // Change to your database username
$password = ""; // Change to your database password

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

    // Query to get user information
    $sql = "SELECT 
                id,
                name,
                username,
                email,
                country,
                account_type,
                role,
                created_at
            FROM users
            WHERE id = :user_id
            LIMIT 1";
    
    $stmt = $pdo->prepare($sql);
    $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);
    $stmt->execute();
    
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "User not found"
        ]);
        exit();
    }
    
    // Prepare user data
    $userData = [
        "id" => intval($user['id']),
        "name" => $user['name'] ?? $user['username'] ?? "User",
        "username" => $user['username'] ?? "",
        "email" => $user['email'] ?? "",
        "country" => $user['country'] ?? "",
        "account_type" => $user['account_type'] ?? $user['role'] ?? "Regular User",
        "created_at" => $user['created_at'] ?? ""
    ];
    
    echo json_encode([
        "status" => "success",
        "user" => $userData
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

