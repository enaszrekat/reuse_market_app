<?php
/**
 * SEND MESSAGE API - Reference Implementation
 * 
 * This file shows the correct backend implementation for sending messages.
 * The frontend sends:
 *   - conversation_id
 *   - sender_id
 *   - receiver_id
 *   - message
 * 
 * Expected messages table structure:
 *   - id (auto increment)
 *   - conversation_id (INT)
 *   - sender_id (INT)
 *   - receiver_id (INT)
 *   - message (TEXT)
 *   - created_at (DATETIME/TIMESTAMP)
 *   - is_read (TINYINT, default 0)
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Database configuration
$host = 'localhost';
$dbname = 'market_app';
$username = 'root';
$password = '';

try {
    // Connect to database
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Get POST data
    $conversation_id = isset($_POST['conversation_id']) ? intval($_POST['conversation_id']) : 0;
    $sender_id = isset($_POST['sender_id']) ? intval($_POST['sender_id']) : 0;
    $receiver_id = isset($_POST['receiver_id']) ? intval($_POST['receiver_id']) : 0;
    $message = isset($_POST['message']) ? trim($_POST['message']) : '';
    
    // Log received data
    error_log("send_message.php - Received data:");
    error_log("  conversation_id: $conversation_id");
    error_log("  sender_id: $sender_id");
    error_log("  receiver_id: $receiver_id");
    error_log("  message: " . substr($message, 0, 100));
    
    // VALIDATION - All fields are required
    if ($conversation_id <= 0) {
        http_response_code(400);
        echo json_encode([
            'status' => 'error',
            'message' => 'Invalid conversation_id'
        ]);
        error_log("send_message.php - ERROR: Invalid conversation_id");
        exit;
    }
    
    if ($sender_id <= 0) {
        http_response_code(400);
        echo json_encode([
            'status' => 'error',
            'message' => 'Invalid sender_id'
        ]);
        error_log("send_message.php - ERROR: Invalid sender_id");
        exit;
    }
    
    if ($receiver_id <= 0) {
        http_response_code(400);
        echo json_encode([
            'status' => 'error',
            'message' => 'Invalid receiver_id'
        ]);
        error_log("send_message.php - ERROR: Invalid receiver_id");
        exit;
    }
    
    if (empty($message)) {
        http_response_code(400);
        echo json_encode([
            'status' => 'error',
            'message' => 'Message cannot be empty'
        ]);
        error_log("send_message.php - ERROR: Empty message");
        exit;
    }
    
    // Verify conversation exists
    $stmt = $pdo->prepare("SELECT id FROM conversations WHERE id = ?");
    $stmt->execute([$conversation_id]);
    if ($stmt->rowCount() == 0) {
        http_response_code(404);
        echo json_encode([
            'status' => 'error',
            'message' => 'Conversation not found'
        ]);
        error_log("send_message.php - ERROR: Conversation $conversation_id not found");
        exit;
    }
    
    // INSERT MESSAGE INTO DATABASE
    $stmt = $pdo->prepare("
        INSERT INTO messages (
            conversation_id,
            sender_id,
            receiver_id,
            message,
            created_at,
            is_read
        ) VALUES (
            :conversation_id,
            :sender_id,
            :receiver_id,
            :message,
            NOW(),
            0
        )
    ");
    
    $stmt->bindParam(':conversation_id', $conversation_id, PDO::PARAM_INT);
    $stmt->bindParam(':sender_id', $sender_id, PDO::PARAM_INT);
    $stmt->bindParam(':receiver_id', $receiver_id, PDO::PARAM_INT);
    $stmt->bindParam(':message', $message, PDO::PARAM_STR);
    
    // Execute INSERT
    try {
        $stmt->execute();
        $message_id = $pdo->lastInsertId();
        
        error_log("send_message.php - SUCCESS: Message inserted with ID: $message_id");
        
        // Verify the message was actually inserted
        $verify_stmt = $pdo->prepare("SELECT * FROM messages WHERE id = ?");
        $verify_stmt->execute([$message_id]);
        $inserted_message = $verify_stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$inserted_message) {
            http_response_code(500);
            echo json_encode([
                'status' => 'error',
                'message' => 'Message was not saved to database'
            ]);
            error_log("send_message.php - ERROR: Message ID $message_id not found after insert");
            exit;
        }
        
        // Return success with message ID
        http_response_code(200);
        echo json_encode([
            'status' => 'success',
            'message_id' => $message_id,
            'message' => 'Message sent successfully',
            'data' => [
                'id' => $inserted_message['id'],
                'conversation_id' => $inserted_message['conversation_id'],
                'sender_id' => $inserted_message['sender_id'],
                'receiver_id' => $inserted_message['receiver_id'],
                'message' => $inserted_message['message'],
                'created_at' => $inserted_message['created_at']
            ]
        ]);
        
    } catch (PDOException $e) {
        // Log SQL error
        error_log("send_message.php - SQL ERROR: " . $e->getMessage());
        error_log("send_message.php - SQL ERROR CODE: " . $e->getCode());
        
        http_response_code(500);
        echo json_encode([
            'status' => 'error',
            'message' => 'Database error: ' . $e->getMessage(),
            'error_code' => $e->getCode()
        ]);
        exit;
    }
    
} catch (PDOException $e) {
    // Database connection error
    error_log("send_message.php - DATABASE CONNECTION ERROR: " . $e->getMessage());
    
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Database connection failed'
    ]);
    exit;
    
} catch (Exception $e) {
    // General error
    error_log("send_message.php - GENERAL ERROR: " . $e->getMessage());
    
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'An error occurred: ' . $e->getMessage()
    ]);
    exit;
}
?>

