<?php
/**
 * Admin Recent Activity
 * Returns recent user registrations and system activity
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
    $activity = [];
    
    // Recently registered users (last 10)
    $result = $conn->query("
        SELECT id, name, email, country, created_at 
        FROM users 
        ORDER BY created_at DESC 
        LIMIT 10
    ");
    
    $recentUsers = [];
    while ($row = $result->fetch_assoc()) {
        $recentUsers[] = [
            "id" => intval($row['id']),
            "name" => $row['name'] ?? "",
            "email" => $row['email'] ?? "",
            "country" => $row['country'] ?? "",
            "created_at" => $row['created_at'] ?? ""
        ];
    }
    $activity['recent_users'] = $recentUsers;
    
    // Recent messages (if messages table exists)
    $result = $conn->query("SHOW TABLES LIKE 'messages'");
    if ($result->num_rows > 0) {
        $result = $conn->query("
            SELECT COUNT(*) as count, DATE(created_at) as date 
            FROM messages 
            WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
            GROUP BY DATE(created_at)
            ORDER BY date DESC
            LIMIT 7
        ");
        
        $recentMessages = [];
        while ($row = $result->fetch_assoc()) {
            $recentMessages[] = [
                "date" => $row['date'],
                "count" => intval($row['count'])
            ];
        }
        $activity['recent_messages'] = $recentMessages;
    } else {
        $activity['recent_messages'] = [];
    }
    
    echo json_encode([
        "status" => "success",
        "activity" => $activity
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch activity"
    ]);
}
?>

