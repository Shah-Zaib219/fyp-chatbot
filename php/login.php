<?php
session_start();
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Database connection
$host = "localhost";
$user = "root";
$password = "";
$database = "cui_atd";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed: " . $conn->connect_error]));
}

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $input = json_decode(file_get_contents("php://input"), true);

    if (!isset($input['username']) || !isset($input['password'])) {
        echo json_encode(["status" => "error", "message" => "Missing username or password"]);
        exit;
    }

    $username = strtolower(trim($input['username'])); // Ensure lowercase
    $password = trim($input['password']);

    if (empty($username) || empty($password)) {
        echo json_encode(["status" => "error", "message" => "Fields cannot be empty"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT sl.username, sl.password, sl.status, s.regno 
                          FROM student_login sl
                          JOIN students s ON sl.student_id = s.id
                          WHERE sl.username = ? LIMIT 1");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 1) {
        $row = $result->fetch_assoc();

        if ($row['status'] !== 'active') {
            echo json_encode(["status" => "error", "message" => "Your account is blocked"]);
            exit;
        }

        // Check both hashed and non-hashed password
        $isValid = false;
        
        // First try password_verify for hashed passwords
        if (password_verify($password, $row['password'])) {
            $isValid = true;
        } 
        // If that fails, check direct string comparison for non-hashed passwords
        else if ($password === $row['password']) {
            $isValid = true;
        }

        if ($isValid) {
            $_SESSION['username'] = $row['username'];
            $_SESSION['regno'] = $row['regno'];
            echo json_encode([
                "status" => "success", 
                "message" => "Login successful",
                "data" => [
                    "username" => $row['username'],
                    "regno" => $row['regno']
                ]
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Invalid password"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "User not found"]);
    }

    $stmt->close();
}

$conn->close();
?>