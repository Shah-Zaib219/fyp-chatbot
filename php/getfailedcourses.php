<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database connection
$dbHost = 'localhost';
$dbUser = 'root';
$dbPass = '';
$dbName = 'cui_atd';

$conn = new mysqli($dbHost, $dbUser, $dbPass, $dbName);

if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(['error' => 'Database connection failed: ' . $conn->connect_error]));
}

// Function to fetch failed courses
function getFailedCourses($conn, $regno) {
    // Get student ID with more robust query
    $studentQuery = "SELECT id, regno FROM students WHERE regno = ?";
    $stmt = $conn->prepare($studentQuery);
    $stmt->bind_param("s", $regno);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        return ['error' => "Student with registration number $regno not found"];
    }
    
    $student = $result->fetch_assoc();
    $studentId = $student['id'];

    // Fetch all completed courses with grades
    $query = "SELECT 
                c.code,
                c.title,
                co.semester,
                c.credit_hours,
                IFNULL(fg.total_marks, 0) as marks,
                IFNULL(fg.grade, 'F') as grade,
                IFNULL(fg.grade_points, 0) as grade_points
              FROM student_courses sc
              JOIN course_offerings co ON sc.course_offering_id = co.id
              JOIN courses c ON co.course_id = c.id
              LEFT JOIN final_grades fg ON fg.student_course_id = sc.id
              WHERE sc.student_id = ?
              AND sc.status = 'completed'
              ORDER BY co.semester, c.code";
    
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $studentId);
    $stmt->execute();
    $result = $stmt->get_result();

    $failedCourses = [];
    while ($row = $result->fetch_assoc()) {
        // Check if course is failed (grade F or marks < 50 if grade not F)
        $isFailed = false;
        $failureReason = '';
        
        if ($row['grade'] === 'F') {
            $isFailed = true;
            $failureReason = 'Failed (Grade F)';
        } elseif ($row['marks'] < 50) {
            $isFailed = true;
            $failureReason = 'Scored below passing marks (50%)';
        }

        if ($isFailed) {
            $row['failure_reason'] = $failureReason;
            $failedCourses[] = $row;
        }
    }

    return [
        'student_regno' => $student['regno'],
        'failed_courses' => $failedCourses,
        'count' => count($failedCourses)
    ];
}

// Handle GET request
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (!isset($_GET['regno'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Registration number is required']);
        exit;
    }

    $regno = strtoupper(trim($_GET['regno']));
    
    // Validate registration number format
    if (!preg_match('/^(FA|SP)\d{2}-(BCS|BSE)-\d{3}$/', $regno)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid registration number format']);
        exit;
    }

    $response = getFailedCourses($conn, $regno);

    echo json_encode($response);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}

$conn->close();
?>