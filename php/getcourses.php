<?php
// Enable CORS for web
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Origin');
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Origin');
    exit(0);
}

$db_host = 'localhost';
$db_user = 'root';
$db_pass = '';
$db_name = 'cui_atd';

$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);
if ($conn->connect_error) {
    die(json_encode(['error' => "Connection failed: " . $conn->connect_error]));
}

if (!isset($_GET['regno'])) {
    echo json_encode(['error' => 'Registration number required']);
    exit;
}

$regno = $_GET['regno'];

// Get student's details including type and current section
$student_query = "SELECT s.id, s.current_semester, b.session, s.type, sec.id as section_id
                 FROM students s 
                 JOIN batches b ON s.batch_id = b.id 
                 JOIN sections sec ON sec.batch_id = b.id AND sec.semester = s.current_semester
                 WHERE s.regno = ?";
$stmt = $conn->prepare($student_query);
$stmt->bind_param("s", $regno);
$stmt->execute();
$student_result = $stmt->get_result();
$student = $student_result->fetch_assoc();

if (!$student) {
    echo json_encode(['error' => 'Student not found']);
    exit;
}

// Get student's completed courses with grades
$completed_courses_query = "SELECT c.code, c.title, fg.grade, fg.grade_points
                          FROM student_courses sc
                          JOIN course_offerings co ON sc.course_offering_id = co.id
                          JOIN courses c ON co.course_id = c.id
                          JOIN final_grades fg ON sc.id = fg.student_course_id
                          WHERE sc.student_id = ? AND sc.status = 'completed'";
$stmt = $conn->prepare($completed_courses_query);
$stmt->bind_param("i", $student['id']);
$stmt->execute();
$completed_result = $stmt->get_result();
$completed_courses = [];
while ($row = $completed_result->fetch_assoc()) {
    $completed_courses[$row['code']] = $row;
}

$eligible_courses = [];

if ($student['type'] == 'regular') {
    // For regular students, show only their section's courses
    $available_courses_query = "SELECT DISTINCT c.id, c.code, c.title, c.credit_hours, co.id as offering_id
                              FROM course_offerings co
                              JOIN courses c ON co.course_id = c.id
                              JOIN sections s ON co.section_id = s.id
                              WHERE s.id = ? AND s.semester = ?";
    $stmt = $conn->prepare($available_courses_query);
    $stmt->bind_param("ii", $student['section_id'], $student['current_semester']);
} else {
    // For irregular students, show failed/incomplete courses from all sections
    $available_courses_query = "SELECT DISTINCT c.id, c.code, c.title, c.credit_hours, co.id as offering_id
                              FROM course_offerings co
                              JOIN courses c ON co.course_id = c.id
                              JOIN sections s ON co.section_id = s.id
                              JOIN batches b ON s.batch_id = b.id
                              WHERE b.session = ? AND s.semester = ?";
    $stmt = $conn->prepare($available_courses_query);
    $stmt->bind_param("si", $student['session'], $student['current_semester']);
}

$stmt->execute();
$available_result = $stmt->get_result();

$total_credits = 0;
$course_codes = [];

while ($course = $available_result->fetch_assoc()) {
    // Skip if course is already completed with passing grade
    if (isset($completed_courses[$course['code']]) && 
        $completed_courses[$course['code']]['grade_points'] >= 2.0) {
        continue;
    }

    // Check if we've already added this course code
    if (in_array($course['code'], $course_codes)) {
        continue;
    }

    // Check if adding this course would exceed 21 credit hours
    if ($total_credits + $course['credit_hours'] > 21) {
        continue;
    }

    $eligible_courses[] = [
        'id' => $course['id'],
        'code' => $course['code'],
        'title' => $course['title'],
        'credit_hours' => $course['credit_hours'],
        'offering_id' => $course['offering_id']
    ];

    $course_codes[] = $course['code'];
    $total_credits += $course['credit_hours'];
}

echo json_encode([
    'courses' => $eligible_courses,
    'total_credits' => $total_credits,
    'student_type' => $student['type']
]);
?>