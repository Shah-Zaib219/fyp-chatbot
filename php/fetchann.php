<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database configuration
$host = "localhost";
$user = "root";
$password = "";
$database = "cui_atd";

// Create connection
$conn = new mysqli($host, $user, $password, $database);

// Check connection
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed",
        "error" => $conn->connect_error
    ]);
    exit();
}

try {
    // Get current date for filtering active announcements
    $currentDate = date('Y-m-d');
    
    // Prepare SQL query to fetch announcements
    // This fetches announcements that are either for everyone, or match the student's program/batch/section
    // In a real app, you would pass student details and filter accordingly
    $sql = "SELECT a.id, a.title, a.content, a.post_date, 
                   a.target, a.target_id, a.expiry_date,
                   u.username AS posted_by
            FROM announcements a
            LEFT JOIN admin_login u ON a.posted_by = u.id
            WHERE (a.expiry_date IS NULL OR a.expiry_date >= '$currentDate')
            ORDER BY a.post_date DESC";

    $result = $conn->query($sql);

    if (!$result) {
        throw new Exception("Query failed: " . $conn->error);
    }

    if ($result->num_rows > 0) {
        $announcements = array();
        
        while($row = $result->fetch_assoc()) {
            // Format the post_date for better readability
            $row['post_date'] = date("M d, Y h:i A", strtotime($row['post_date']));
            $announcements[] = $row;
        }
        
        http_response_code(200);
        echo json_encode([
            "status" => "success",
            "announcements" => $announcements,
            "count" => count($announcements)
        ]);
    } else {
        http_response_code(404);
        echo json_encode([
            "status" => "success",
            "message" => "No announcements found",
            "announcements" => []
        ]);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Server error",
        "error" => $e->getMessage()
    ]);
} finally {
    $conn->close();
}
?>