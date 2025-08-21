<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json");

header('Content-Type: application/json');
$conn = new mysqli("localhost", "root", "", "cui_atd");

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "DB connection failed"]);
    exit();
}

$result = $conn->query("SELECT * FROM allow_options WHERE id = 1");

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode([
        "status" => "success",
        "course_offering" => $row['course_offering']
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "No entry found"]);
}

$conn->close();
?>
