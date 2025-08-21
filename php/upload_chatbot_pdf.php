<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json");

$conn = new mysqli("localhost", "root", "", "cui_atd");

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "DB connection failed"]);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_FILES['pdf']) && $_FILES['pdf']['error'] === 0) {
        $filename = $_FILES['pdf']['name'];
        $tmpname = $_FILES['pdf']['tmp_name'];
        $upload_dir = "chatbot_pdfs/";

        if (!is_dir($upload_dir)) {
            mkdir($upload_dir, 0777, true);
        }

        $target_file = $upload_dir . basename($filename);
        move_uploaded_file($tmpname, $target_file);

        $department = $_POST['department'];
        $session_start = $_POST['session_start'];
        $session_end = $_POST['session_end'];
        $added_by = $_POST['added_by'];

        $stmt = $conn->prepare("INSERT INTO chatbot_document (department, session_start, session_end, file_path, added_by) VALUES (?, ?, ?, ?, ?)");
        $stmt->bind_param("sssss", $department, $session_start, $session_end, $target_file, $added_by);
        if ($stmt->execute()) {
            echo json_encode(["status" => "success"]);
        } else {
            echo json_encode(["status" => "error", "message" => "DB insert failed"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "No file or file error"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request"]);
}
?>
