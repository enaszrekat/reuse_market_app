<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

// ✅ منع عرض أخطاء PHP كـ HTML
error_reporting(E_ALL);
ini_set('display_errors', 0); // لا نعرض الأخطاء للمستخدم
ini_set('log_errors', 1); // نسجل الأخطاء في error log

$conn = new mysqli("localhost", "root", "", "market_app");
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "DB connection failed: " . $conn->connect_error]);
    error_log("send_message.php - DB connection failed: " . $conn->connect_error);
    exit;
}

// ✅ Flutter يرسل conversation_id مباشرة (ليس product_id)
$conversation_id = intval($_POST['conversation_id'] ?? 0);
$sender_id       = intval($_POST['sender_id'] ?? 0);
$receiver_id     = intval($_POST['receiver_id'] ?? 0);
$message         = trim($_POST['message'] ?? "");

// ✅ تسجيل البيانات المستلمة
error_log("send_message.php - Received: conversation_id=$conversation_id, sender_id=$sender_id, receiver_id=$receiver_id, message_length=" . strlen($message));

// ✅ التحقق من صحة البيانات
if ($conversation_id === 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Invalid conversation_id"]);
    error_log("send_message.php - ERROR: Invalid conversation_id");
    exit;
}

if ($sender_id === 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Invalid sender_id"]);
    error_log("send_message.php - ERROR: Invalid sender_id");
    exit;
}

if ($receiver_id === 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Invalid receiver_id"]);
    error_log("send_message.php - ERROR: Invalid receiver_id");
    exit;
}

if ($message === "") {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Message cannot be empty"]);
    error_log("send_message.php - ERROR: Empty message");
    exit;
}

// ✅ التحقق من وجود conversation في قاعدة البيانات
$stmt = $conn->prepare("SELECT id FROM conversations WHERE id = ?");
$stmt->bind_param("i", $conversation_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    http_response_code(404);
    echo json_encode([
        "status" => "error",
        "message" => "Conversation not found. conversation_id=$conversation_id does not exist in database"
    ]);
    error_log("send_message.php - ERROR: Conversation $conversation_id not found");
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// ✅ إدخال الرسالة في قاعدة البيانات
$stmt = $conn->prepare("
    INSERT INTO messages (conversation_id, sender_id, receiver_id, message, created_at, is_read)
    VALUES (?, ?, ?, ?, NOW(), 0)
");

if (!$stmt) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Failed to prepare statement: " . $conn->error
    ]);
    error_log("send_message.php - ERROR: Failed to prepare statement: " . $conn->error);
    $conn->close();
    exit;
}

$stmt->bind_param("iiis", $conversation_id, $sender_id, $receiver_id, $message);

if (!$stmt->execute()) {
    // ✅ تسجيل خطأ SQL بالتفصيل
    $error_msg = $stmt->error;
    $error_code = $stmt->errno;
    
    error_log("send_message.php - SQL ERROR: $error_msg (Code: $error_code)");
    error_log("send_message.php - SQL ERROR - conversation_id: $conversation_id, sender_id: $sender_id, receiver_id: $receiver_id");
    
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Failed to insert message: " . $error_msg,
        "error_code" => $error_code
    ]);
    $stmt->close();
    $conn->close();
    exit;
}

// ✅ الحصول على معرف الرسالة المُدرجة
$message_id = $stmt->insert_id;
$stmt->close();

// ✅ التحقق من أن الرسالة تم حفظها فعلياً
$verify_stmt = $conn->prepare("SELECT id, conversation_id, sender_id, receiver_id, message, created_at FROM messages WHERE id = ?");
$verify_stmt->bind_param("i", $message_id);
$verify_stmt->execute();
$verify_result = $verify_stmt->get_result();

if ($verify_result->num_rows === 0) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Message was not saved to database. INSERT succeeded but message not found."
    ]);
    error_log("send_message.php - ERROR: Message ID $message_id not found after insert");
    $verify_stmt->close();
    $conn->close();
    exit;
}

$inserted_message = $verify_result->fetch_assoc();
$verify_stmt->close();

// ✅ تسجيل النجاح
error_log("send_message.php - SUCCESS: Message inserted with ID: $message_id");

// ✅ إرجاع النجاح مع بيانات الرسالة
http_response_code(200);
echo json_encode([
    "status" => "success",
    "message_id" => $message_id,
    "conversation_id" => $conversation_id,
    "message" => "Message sent successfully",
    "data" => $inserted_message
]);

$conn->close();
?>

