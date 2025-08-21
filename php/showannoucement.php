<?php
session_start();
header("Content-Type: application/json");

$host = "localhost";
$user = "root";
$password = "";
$database = "cui_atd";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed: " . $conn->connect_error]));
}

$sql = "SELECT a.id, a.title, a.details, a.posted_at, u.username AS posted_by
        FROM announcements a
        JOIN admin_login u ON a.posted_by = u.id
        ORDER BY a.posted_at DESC";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $announcements = [];
    while ($row = $result->fetch_assoc()) {
        $announcements[] = $row;
    }
    echo json_encode(["status" => "success", "announcements" => $announcements]);
} else {
    echo json_encode(["status" => "error", "message" => "No announcements found"]);
}

$conn->close();
?>
