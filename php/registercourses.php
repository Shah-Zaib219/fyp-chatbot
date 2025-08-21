<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include './connection/connection.php';

$data = json_decode(file_get_contents("php://input"), true);
$regno = $data['regno'] ?? '';
$section_ids = $data['sections'] ?? [];

if (empty($regno)) {
    echo json_encode(['error' => 'Registration number required']);
    exit;
}

if (empty($section_ids)) {
    echo json_encode(['error' => 'No sections selected']);
    exit;
}

try {
    $conn->begin_transaction();
    
    // Get student ID and current semester
    $stmt = $conn->prepare("
        SELECT s.id, s.current_semester 
        FROM students s 
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
    $student_id = $student['id'];
    $current_semester = $student['current_semester'];
    $registration_date = date('Y-m-d');
    
    // Register for each section
    foreach ($section_ids as $section_id) {
        // Verify section exists and is open
        $stmt = $conn->prepare("
            SELECT co.id 
            FROM course_offerings co
            JOIN sections s ON co.section_id = s.id
            WHERE s.id = ? 
            AND co.status = 'open'
            AND s.semester = ?
        ");
        $stmt->bind_param("ii", $section_id, $current_semester);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            throw new Exception("Invalid or closed section: $section_id");
        }
        
        $offering = $result->fetch_assoc();
        $offering_id = $offering['id'];
        
        // Check if already registered
        $stmt = $conn->prepare("
            SELECT 1 
            FROM student_courses 
            WHERE student_id = ? 
            AND course_offering_id = ?
            AND status = 'registered'
        ");
        $stmt->bind_param("ii", $student_id, $offering_id);
        $stmt->execute();
        
        if ($stmt->get_result()->num_rows > 0) {
            continue; // Skip if already registered
        }
        
        // Register student
        $stmt = $conn->prepare("
            INSERT INTO student_courses 
            (student_id, course_offering_id, registration_date, status) 
            VALUES (?, ?, ?, 'registered')
        ");
        $stmt->bind_param("iis", $student_id, $offering_id, $registration_date);
        $stmt->execute();
    }
    
    $conn->commit();
    echo json_encode(['success' => true]);
    
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(['error' => $e->getMessage()]);
}

$conn->close();
?>