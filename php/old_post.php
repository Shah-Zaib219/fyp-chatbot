<!-- <?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

$servername = "localhost";
$username = "root";
$password = "";
$database = "cui_atd";

$conn = new mysqli($servername, $username, $password, $database);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed",
        "error" => $conn->connect_error
    ]);
    exit();
}

// Read and decode JSON
$json = file_get_contents("php://input");
$data = json_decode($json, true);

if (!isset($data['title'], $data['content'], $data['posted_by'], $data['target'])) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Missing required fields",
        "received_data" => $data
    ]);
    exit();
}

$title = $conn->real_escape_string($data['title']);
$content = $conn->real_escape_string($data['content']);
$posted_by = intval($data['posted_by']);
$target = $conn->real_escape_string($data['target']);
$target_id = isset($data['target_id']) ? intval($data['target_id']) : null;

if (!in_array($target, ['all', 'batch', 'program', 'section'])) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Invalid target type"
    ]);
    exit();
}

// Set target_id to null if target is "all"
if ($target === 'all') {
    $target_id = null;
}

$sql = "INSERT INTO announcements (title, content, target, target_id, posted_by, post_date)
        VALUES (?, ?, ?, ?, ?, NOW())";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "SQL Prepare failed",
        "error" => $conn->error
    ]);
    exit();
}

// Use 's' for NULL, 'i' for integer — always bind as nullable
$stmt->bind_param("sssii", $title, $content, $target, $target_id, $posted_by);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Announcement posted successfully!",
        "id" => $stmt->insert_id
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Failed to post announcement",
        "error" => $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?> -->