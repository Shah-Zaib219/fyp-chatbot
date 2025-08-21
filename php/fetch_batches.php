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

$sql = "SELECT DISTINCT session FROM batches WHERE status = 'active' ORDER BY session DESC";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $batches = [];
    while($row = $result->fetch_assoc()) {
        $batches[] = $row['session'];
    }
    echo json_encode(["status" => "success", "batches" => $batches]);
} else {
    echo json_encode(["status" => "success", "batches" => []]);
}

$conn->close();
?>