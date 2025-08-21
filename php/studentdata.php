<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$host = "localhost";
$username = "root";
$password = "";
$database = "cui_atd";

// Create connection
$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$regno = $_GET['regno'] ?? '';

if (empty($regno)) {
    echo json_encode(["error" => "Registration number is required"]);
    exit;
}

// Query to get comprehensive student data
$sql = "SELECT 
            s.*, 
            p.name AS program_name,
            b.session AS batch_session,
            (SELECT COUNT(*) FROM student_courses sc WHERE sc.student_id = s.id AND sc.status = 'registered') AS total_courses,
            (SELECT GROUP_CONCAT(c.code SEPARATOR ', ') 
             FROM student_courses sc 
             JOIN course_offerings co ON sc.course_offering_id = co.id
             JOIN courses c ON co.course_id = c.id
             WHERE sc.student_id = s.id AND sc.status = 'registered') AS registered_courses,
            (SELECT AVG(fg.grade_points) 
             FROM student_courses sc 
             JOIN final_grades fg ON sc.id = fg.student_course_id
             WHERE sc.student_id = s.id) AS cgpa
        FROM students s
        JOIN programs p ON s.program_id = p.id
        JOIN batches b ON s.batch_id = b.id
        WHERE s.regno = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $regno);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $student = $result->fetch_assoc();
    
    // Format the data for better presentation
    $student['cgpa'] = number_format((float)$student['cgpa'], 2);
    $student['registered_courses'] = explode(', ', $student['registered_courses']);
    
    echo json_encode($student);
} else {
    echo json_encode(["error" => "Student not found"]);
}

$stmt->close();
$conn->close();
?>