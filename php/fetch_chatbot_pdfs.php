<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

$conn = new mysqli("localhost", "root", "", "cui_atd");

$sql = "SELECT * FROM chatbot_document ORDER BY id DESC";
$result = $conn->query($sql);

$documents = [];

while ($row = $result->fetch_assoc()) {
    $documents[] = $row;
}

echo json_encode(["status" => "success", "documents" => $documents]);
?>
