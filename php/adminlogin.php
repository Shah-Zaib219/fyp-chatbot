<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json");

// Database configuration
$host = "localhost";
$user = "root";
$pass = "";
$dbname = "cui_atd";

// Create connection
$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    die(json_encode([
        "status" => "error", 
        "message" => "DB connection failed: " . $conn->connect_error
    ]));
}

// Get input data
$data = json_decode(file_get_contents("php://input"), true);

// Validate input
if (!isset($data['username']) || !isset($data['password'])) {
    die(json_encode([
        "status" => "error", 
        "message" => "Username and password required"
    ]));
}

$username = trim($data['username']);
$password = trim($data['password']);

// Query database
$sql = "SELECT * FROM admin_login WHERE username = ? AND status = 'active'";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    die(json_encode([
        "status" => "error", 
        "message" => "Prepare failed: " . $conn->error
    ]));
}

$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $row = $result->fetch_assoc();
    
    if (password_verify($password, $row['password'])) {
        echo json_encode([
            "status" => "success",
            "data" => [
                "id" => $row['id'],
                "role" => $row['role'],
                "department_id" => $row['department_id']
            ]
        ]);
    } else {
        echo json_encode([
            "status" => "error", 
            "message" => "Incorrect password"
        ]);
    }
} else {
    echo json_encode([
        "status" => "error", 
        "message" => "Username not found or account inactive"
    ]);
}

$stmt->close();
$conn->close();
?>