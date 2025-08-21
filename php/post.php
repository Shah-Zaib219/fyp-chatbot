
<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$uploadDir = "uploads/announcements/";
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

$servername = "localhost";
$username = "root";
$password = "";
$database = "cui_atd";

$conn = new mysqli($servername, $username, $password, $database);
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit();
}

// Collect POST data
$title = $_POST['title'] ?? '';
$content = $_POST['content'] ?? '';
$posted_by = $_POST['posted_by'] ?? '';
$target = $_POST['target'] ?? '';
$target_id = $_POST['target_id'] ?? null;

if (empty($title) || empty($content) || empty($posted_by) || empty($target)) {
    echo json_encode(["status" => "error", "message" => "Missing required fields"]);
    exit();
}

// Sanitize data
$title = $conn->real_escape_string($title);
$content = $conn->real_escape_string($content);
$posted_by = (int) $posted_by;
$target_id = $target === 'all' ? null : (int) $target_id;

// Handle image upload
$imageFileName = null;
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $tmpName = $_FILES['image']['tmp_name'];
    $baseName = basename($_FILES['image']['name']);
    $uniqueName = time() . "_" . preg_replace("/[^a-zA-Z0-9.]/", "_", $baseName);
    $targetPath = $uploadDir . $uniqueName;

    if (move_uploaded_file($tmpName, $targetPath)) {
        $imageFileName = $uniqueName;
    }
}

$sql = "INSERT INTO announcements (title, content, image, target, target_id, posted_by, post_date)
        VALUES (?, ?, ?, ?, ?, ?, NOW())";

$stmt = $conn->prepare($sql);
$stmt->bind_param("ssssii", $title, $content, $imageFileName, $target, $target_id, $posted_by);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Announcement posted!", "id" => $stmt->insert_id]);
} else {
    echo json_encode(["status" => "error", "message" => "Insert failed", "error" => $stmt->error]);
}

$stmt->close();
$conn->close();
?>
