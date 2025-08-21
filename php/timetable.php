<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database config
$dbHost = 'localhost';
$dbUser = 'root';
$dbPass = '';
$dbName = 'cui_atd';

// Create connection
$conn = new mysqli($dbHost, $dbUser, $dbPass, $dbName);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed: ' . $conn->connect_error]);
    exit;
}

// Function to fetch timetable
function getStudentTimetable($conn, $regno) {
    if (!preg_match('/^[A-Za-z0-9-]+$/', $regno)) {
        return ['error' => 'Invalid registration number format'];
    }

    // Get student basic info
    $studentQuery = "SELECT s.id, s.current_semester, b.session, p.code as program_code, s.batch_id
                     FROM students s
                     JOIN batches b ON s.batch_id = b.id
                     JOIN programs p ON s.program_id = p.id
                     WHERE s.regno = ?";
    $stmt = $conn->prepare($studentQuery);
    $stmt->bind_param("s", $regno);
    $stmt->execute();
    $studentResult = $stmt->get_result();

    if ($studentResult->num_rows === 0) {
        return ['error' => 'Student not found'];
    }

    $student = $studentResult->fetch_assoc();
    $batchId = $student['batch_id'];
    $currentSemester = $student['current_semester'];

    // Get section
    $sectionQuery = "SELECT id FROM sections 
                     WHERE batch_id = ? AND semester = ? AND name = 'A' LIMIT 1";
    $stmt = $conn->prepare($sectionQuery);
    $stmt->bind_param("ii", $batchId, $currentSemester);
    $stmt->execute();
    $sectionResult = $stmt->get_result();

    if ($sectionResult->num_rows === 0) {
        return ['error' => 'Section not found for student'];
    }

    $section = $sectionResult->fetch_assoc();
    $sectionId = $section['id'];

    // Get timetable entries
    $timetableQuery = "SELECT 
                        ts.day,
                        TIME_FORMAT(ts.start_time, '%H:%i') as start_time,
                        TIME_FORMAT(ts.end_time, '%H:%i') as end_time,
                        c.code as course_code,
                        c.title as course_title,
                        f.name as faculty_name,
                        t.room,
                        'primary' as status_color
                      FROM timetable t
                      JOIN time_slots ts ON t.time_slot_id = ts.id
                      JOIN course_offerings co ON t.course_offering_id = co.id
                      JOIN courses c ON co.course_id = c.id
                      JOIN faculty f ON co.faculty_id = f.id
                      WHERE co.section_id = ?
                      ORDER BY 
                        FIELD(ts.day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'),
                        ts.start_time";

    $stmt = $conn->prepare($timetableQuery);
    $stmt->bind_param("i", $sectionId);
    $stmt->execute();
    $timetableResult = $stmt->get_result();

    $timetable = [];
    while ($row = $timetableResult->fetch_assoc()) {
        $timetable[] = $row;
    }

    if (empty($timetable)) {
        return ['error' => 'No timetable entries found'];
    }

    return [
        'type' => 'regular',
        'timetable' => $timetable,
        'semester' => $currentSemester,
        'session' => $student['session']
    ];
}

// Handle GET request
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (!isset($_GET['regno'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Registration number is required']);
        exit;
    }

    $regno = trim($_GET['regno']);
    $response = getStudentTimetable($conn, $regno);

    if (isset($response['error'])) {
        http_response_code(404);
    }

    echo json_encode($response);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}

$conn->close();
?>
