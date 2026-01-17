<?php
/**
 * Admin Block User
 * Blocks or unblocks a user (does not affect products)
 * NEW ENDPOINT - Does not modify existing product endpoints
 */

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

error_reporting(0);
ini_set('display_errors', 0);

require_once "db.php";

try {
    $userId = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
    $blocked = isset($_POST['blocked']) ? ($_POST['blocked'] === 'true' || $_POST['blocked'] === '1') : false;
    
    if ($userId <= 0) {
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "Invalid user ID"
        ]);
        exit;
    }
    
    // Check if blocked column exists, if not add it
    $result = $conn->query("SHOW COLUMNS FROM users LIKE 'blocked'");
    if ($result->num_rows == 0) {
        $conn->query("ALTER TABLE users ADD COLUMN blocked TINYINT(1) DEFAULT 0");
    }
    
    // Update user blocked status
    $blockedValue = $blocked ? 1 : 0;
    $stmt = $conn->prepare("UPDATE users SET blocked = ? WHERE id = ?");
    $stmt->bind_param("ii", $blockedValue, $userId);
    $stmt->execute();
    
    echo json_encode([
        "status" => "success",
        "message" => $blocked ? "User blocked successfully" : "User unblocked successfully"
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Failed to update user status"
    ]);
}
?>

