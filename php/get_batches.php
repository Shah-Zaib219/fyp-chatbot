<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

$servername = "localhost";
$username = "root";
$password = "";
$database = "cui_atd";

// Create connection with error handling
try {
    $conn = new mysqli($servername, $username, $password, $database);
    
    if ($conn->connect_error) {
        throw new Exception("Database connection failed: " . $conn->connect_error);
    }

    // Validate and sanitize input
    $departmentId = isset($_GET['department_id']) ? (int)$_GET['department_id'] : null;
    
    if (!$departmentId || $departmentId < 1) {
        http_response_code(400);
        die(json_encode([
            "status" => "error",
            "message" => "Valid department ID is required",
            "data" => []
        ]));
    }

    // Prepare statement with error handling
    $sql = "SELECT b.id, b.session 
            FROM batches b
            JOIN programs p ON b.program_id = p.id
            WHERE p.department_id = ? AND b.status = 'active'";
    
    if (!$stmt = $conn->prepare($sql)) {
        throw new Exception("Prepare failed: " . $conn->error);
    }

    // Bind parameters and execute
    $stmt->bind_param("i", $departmentId);
    if (!$stmt->execute()) {
        throw new Exception("Execute failed: " . $stmt->error);
    }

    // Get result and format response
    $result = $stmt->get_result();
    $batches = [];

    while ($row = $result->fetch_assoc()) {
        // Validate and sanitize each row
        if (!empty($row['id']) && !empty($row['session'])) {
            $batches[] = [
                'id' => (int)$row['id'],
                'session' => htmlspecialchars($row['session'], ENT_QUOTES, 'UTF-8')
            ];
        }
    }

    // Return consistent JSON structure
    echo json_encode([
        "status" => "success",
        "message" => count($batches) . " batches found",
        "data" => $batches
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage(),
        "data" => []
    ]);
} finally {
    if (isset($conn)) {
        $conn->close();
    }
}
?>