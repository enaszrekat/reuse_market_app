<?php
/**
 * Admin Dashboard Statistics
 * Returns statistics for admin dashboard
 * NEW ENDPOINT - Does not modify existing product endpoints
 */

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

error_reporting(0);
ini_set('display_errors', 0);

require_once "db.php";

try {
    $stats = [];
    
    // New users today
    $today = date('Y-m-d');
    $result = $conn->query("SELECT COUNT(*) as count FROM users WHERE DATE(created_at) = '$today'");
    $stats['new_users_today'] = $result->fetch_assoc()['count'] ?? 0;
    
    // Total users
    $result = $conn->query("SELECT COUNT(*) as count FROM users");
    $stats['total_users'] = $result->fetch_assoc()['count'] ?? 0;
    
    // Total products (approved + pending)
    $result = $conn->query("SELECT COUNT(*) as count FROM products");
    $stats['total_products'] = $result->fetch_assoc()['count'] ?? 0;
    
    // Pending products
    $result = $conn->query("SELECT COUNT(*) as count FROM products WHERE status = 'pending'");
    $stats['pending_products'] = $result->fetch_assoc()['count'] ?? 0;
    
    // New messages today (if messages table exists)
    $result = $conn->query("SHOW TABLES LIKE 'messages'");
    if ($result->num_rows > 0) {
        $result = $conn->query("SELECT COUNT(*) as count FROM messages WHERE DATE(created_at) = '$today'");
        $stats['new_messages_today'] = $result->fetch_assoc()['count'] ?? 0;
    } else {
        $stats['new_messages_today'] = 0;
    }
    
    // New notifications today (if notifications table exists)
    $result = $conn->query("SHOW TABLES LIKE 'notifications'");
    if ($result->num_rows > 0) {
        $result = $conn->query("SELECT COUNT(*) as count FROM notifications WHERE DATE(created_at) = '$today'");
        $stats['new_notifications_today'] = $result->fetch_assoc()['count'] ?? 0;
    } else {
        $stats['new_notifications_today'] = 0;
    }
    
    echo json_encode([
        "status" => "success",
        "stats" => $stats
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch statistics"
    ]);
}
?>

