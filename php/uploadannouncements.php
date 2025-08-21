<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");

// Enable detailed error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Create debug log
file_put_contents('debug.log', "\n\n==== NEW REQUEST ====\n", FILE_APPEND);
file_put_contents('debug.log', "Request Time: " . date('Y-m-d H:i:s') . "\n", FILE_APPEND);

// Log all headers
file_put_contents('debug.log', "Headers:\n" . print_r(getallheaders(), true) . "\n", FILE_APPEND);

// Get raw input
$input = file_get_contents('php://input');
file_put_contents('debug.log', "Raw Input:\n$input\n", FILE_APPEND);

// Verify input was received
if (empty($input)) {
    http_response_code(400);
    $response = [
        "status" => "error",
        "message" => "No input data received",
        "debug" => [
            "headers" => getallheaders(),
            "input" => $input
        ]
    ];
    file_put_contents('debug.log', "Error Response:\n" . print_r($response, true) . "\n", FILE_APPEND);
    echo json_encode($response);
    exit();
}

// Decode JSON
$data = json_decode($input, true);

// Check for JSON errors
if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    $response = [
        "status" => "error",
        "message" => "JSON Error: " . json_last_error_msg(),
        "json_error" => json_last_error(),
        "raw_input" => $input
    ];
    file_put_contents('debug.log', "JSON Error:\n" . print_r($response, true) . "\n", FILE_APPEND);
    echo json_encode($response);
    exit();
}

// Log decoded data
file_put_contents('debug.log', "Decoded Data:\n" . print_r($data, true) . "\n", FILE_APPEND);

// Database connection (update with your credentials)
$db_host = "localhost";
$db_name = "cui_atd";
$db_user = "root";
$db_pass = "";

try {
    $conn = new PDO("mysql:host=$db_host;dbname=$db_name", $db_user, $db_pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Validate required fields
    $required = ['title', 'details', 'posted_by'];
    foreach ($required as $field) {
        if (!isset($data[$field]) || empty(trim($data[$field]))) {
            throw new Exception("Field '$field' is required");
        }
    }
    
    // Prepare and execute SQL
    $stmt = $conn->prepare("INSERT INTO announcements 
        (title, details, posted_by, posted_at) 
        VALUES (:title, :details, :posted_by, NOW())");
    
    $stmt->execute([
        ':title' => $data['title'],
        ':details' => $data['details'],
        ':posted_by' => $data['posted_by']
    ]);
    
    $response = [
        "status" => "success",
        "message" => "Announcement created successfully",
        "announcement_id" => $conn->lastInsertId()
    ];
    
    http_response_code(200);
} catch(PDOException $e) {
    $response = [
        "status" => "error",
        "message" => "Database error: " . $e->getMessage(),
        "error_code" => $e->getCode()
    ];
    http_response_code(500);
} catch(Exception $e) {
    $response = [
        "status" => "error",
        "message" => $e->getMessage()
    ];
    http_response_code(400);
}

// Log final response
file_put_contents('debug.log', "Final Response:\n" . print_r($response, true) . "\n", FILE_APPEND);
echo json_encode($response);
?>
