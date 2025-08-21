<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json");

header('Content-Type: application/json');
$conn = new mysqli("localhost", "root", "", "cui_atd");

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Connection failed"]);
    exit();
}

$id = $_POST['id'];
$newStatus = $_POST['status'];

$stmt = $conn->prepare("UPDATE allow_options SET course_offering = ? WHERE id = ?");
$stmt->bind_param("si", $newStatus, $id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => "Update failed"]);
}

$stmt->close();
$conn->close();
?>
