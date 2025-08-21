<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

$servername = "localhost";
$username = "root";
$password = "";
$database = "cui_atd";

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode([
        "status" => "error",
        "message" => "Database connection failed",
        "error" => $conn->connect_error
    ]));
}

// Get the raw POST data
$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Validate required fields
if (!isset($data['title'], $data['content'], $data['posted_by'], $data['target'])) {
    http_response_code(400);
    die(json_encode([
        "status" => "error",
        "message" => "Missing required fields",
        "received_data" => $data // For debugging
    ]));
}

// Prepare data
$title = $conn->real_escape_string($data['title']);
$content = $conn->real_escape_string($data['content']);
$postedBy = (int)$data['posted_by'];
$target = $data['target'];
$targetId = ($target != 'all' && isset($data['target_id'])) 
    ? (int)$data['target_id'] 
    : null;

// Validate target type
$allowedTargets = ['all', 'batch'];
if (!in_array($target, $allowedTargets)) {
    http_response_code(400);
    die(json_encode([
        "status" => "error",
        "message" => "Invalid target type. Allowed: " . implode(', ', $allowedTargets)
    ]));
}

// Insert announcement
$sql = "INSERT INTO announcements 
        (title, content, target, target_id, posted_by, post_date) 
        VALUES (?, ?, ?, ?, ?, NOW())";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    http_response_code(500);
    die(json_encode([
        "status" => "error",
        "message" => "Prepare failed",
        "error" => $conn->error
    ]));
}

$stmt->bind_param("sssii", $title, $content, $target, $targetId, $postedBy);

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
?>