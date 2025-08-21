<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");

$host = "localhost";
$user = "root";
$password = "";
$database = "cui_atd";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed"]));
}

$sql = "SELECT id, code, name FROM programs WHERE status = 'active'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $programs = [];
    while($row = $result->fetch_assoc()) {
        $programs[] = $row;
    }
    echo json_encode(["status" => "success", "programs" => $programs]);
} else {
    echo json_encode(["status" => "success", "programs" => []]);
}

$conn->close();
?>