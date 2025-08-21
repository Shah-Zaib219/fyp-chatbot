<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include './connection/connection.php';
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "cui_atd";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

$data = json_decode(file_get_contents("php://input"), true);
$regno = $data['regno'] ?? '';
$courses = $data['courses'] ?? [];

if (empty($regno)) {
    echo json_encode(['error' => 'Registration number required']);
    exit;
}

if (empty($courses)) {
    echo json_encode(['error' => 'No courses selected']);
    exit;
}

try {
    // Get student details including current semester and batch
    $stmt = $conn->prepare("
        SELECT s.id, s.current_semester, b.id as batch_id, p.id as program_id
        FROM students s
        JOIN batches b ON s.batch_id = b.id
        JOIN programs p ON s.program_id = p.id
        WHERE s.regno = ?
    ");
    $stmt->bind_param("s", $regno);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode(['error' => 'Student not found']);
        exit;
    }
    
    $student = $result->fetch_assoc();
    $current_semester = $student['current_semester'];
    $batch_id = $student['batch_id'];
    $program_id = $student['program_id'];
    
    // Get all sections for selected courses in current semester
    $placeholders = implode(',', array_fill(0, count($courses), '?'));
    $query = "
        SELECT 
            c.id as course_id,
            c.code as course_code,
            c.title as course_title,
            c.credit_hours,
            s.id as section_id,
            s.name as section_name,
            f.id as faculty_id,
            f.name as faculty_name,
            co.id as offering_id
        FROM course_offerings co
        JOIN courses c ON co.course_id = c.id
        JOIN sections s ON co.section_id = s.id
        JOIN faculty f ON co.faculty_id = f.id
        WHERE c.code IN ($placeholders)
        AND s.semester = ?
        AND s.batch_id IN (
            SELECT id FROM batches WHERE program_id = ?
        )
        AND co.status = 'open'
    ";
    
    $stmt = $conn->prepare($query);
    $types = str_repeat('s', count($courses)) . 'ii';
    $params = array_merge($courses, [$current_semester, $program_id]);
    $stmt->bind_param($types, ...$params);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $sections = [];
    while ($row = $result->fetch_assoc()) {
        // Get timetable for each section
        $timetable_query = "
            SELECT 
                ts.day, 
                TIME_FORMAT(ts.start_time, '%H:%i') as start_time,
                TIME_FORMAT(ts.end_time, '%H:%i') as end_time,
                t.room,
                ts.slot_type
            FROM timetable t
            JOIN time_slots ts ON t.time_slot_id = ts.id
            WHERE t.course_offering_id = ?
            ORDER BY 
                FIELD(ts.day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'),
                ts.start_time
        ";
        $t_stmt = $conn->prepare($timetable_query);
        $t_stmt->bind_param("i", $row['offering_id']);
        $t_stmt->execute();
        $t_result = $t_stmt->get_result();
        
        $row['timetable'] = [];
        while ($t_row = $t_result->fetch_assoc()) {
            $row['timetable'][] = $t_row;
        }
        
        $sections[] = $row;
    }
    
    echo json_encode(['sections' => $sections]);
    
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}

$conn->close();
?>