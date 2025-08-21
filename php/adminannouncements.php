<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");

$host = "localhost";
$user = "root";
$password = "";
$database = "cui_atd";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Database connection failed: " . $conn->connect_error]);
    exit;
}

$sql = "SELECT a.id, a.title, a.content, a.image, a.target, a.target_id, a.post_date, a.expiry_date, u.username AS posted_by
        FROM announcements a
        JOIN admin_login u ON a.posted_by = u.id
        ORDER BY a.post_date DESC";

$result = $conn->query($sql);

$announcements = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
     $row['image_url'] = !empty($row['image'])
    ? 'http://10.125.76.114/html/uploads/announcements/' . $row['image']
    : null;


        $announcements[] = $row;
    }
}

$conn->close();

echo json_encode([
    "status" => "success",
    "announcements" => $announcements
]);
?>
