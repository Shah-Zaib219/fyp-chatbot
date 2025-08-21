timetable.
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database configuration - UPDATE THESE WITH YOUR ACTUAL CREDENTIALS
$dbHost = 'localhost';
$dbUser = 'root'; // Default XAMPP username
$dbPass = '';     // Default XAMPP password (empty)
$dbName = 'cui_atd';

// Create connection
try {
    $conn = new mysqli($dbHost, $dbUser, $dbPass, $dbName);
    
    // Check connection
    if ($conn->connect_error) {
        throw new Exception("Database connection failed: " . $conn->connect_error);
    }
} catch (Exception $e) {
    http_response_code(500);
    die(json_encode(['error' => $e->getMessage()]));
}

// Rest of your existing code...
function getStudentTimetable($conn, $regno) {
    // Validate input
    if (!preg_match('/^[A-Za-z0-9-]+$/', $regno)) {
        return ['error' => 'Invalid registration number format'];
    }

    // Get student details
    $studentQuery = "SELECT s.id, s.type, s.current_semester, b.session, p.code as program_code, s.batch_id
                    FROM students s
                    JOIN batches b ON s.batch_id = b.id
                    JOIN programs p ON s.program_id = p.id
                    WHERE s.regno = ?";
    
    $stmt = $conn->prepare($studentQuery);
    if (!$stmt) {
        return ['error' => 'Prepare failed: ' . $conn->error];
    }
    
    $stmt->bind_param("s", $regno);
    if (!$stmt->execute()) {
        return ['error' => 'Execute failed: ' . $stmt->error];
    }
    
    $studentResult = $stmt->get_result();
    if ($studentResult->num_rows === 0) {
        return ['error' => 'Student not found'];
    }
    
    $student = $studentResult->fetch_assoc();
    
    if ($student['type'] === 'regular') {
        // Get section ID for the student's current semester
        $sectionQuery = "SELECT id FROM sections 
                        WHERE batch_id = ? 
                        AND semester = ? 
                        AND name = 'A' 
                        LIMIT 1";
        
        $stmt = $conn->prepare($sectionQuery);
        $batchId = $student['batch_id'];
        $currentSemester = $student['current_semester'];
        $stmt->bind_param("ii", $batchId, $currentSemester);
        if (!$stmt->execute()) {
            return ['error' => 'Section query failed: ' . $stmt->error];
        }
        
        $sectionResult = $stmt->get_result();
        if ($sectionResult->num_rows === 0) {
            return ['error' => 'Section not found for student'];
        }
        
        $section = $sectionResult->fetch_assoc();
        
        // Get timetable entries for the section
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
        $stmt->bind_param("i", $section['id']);
        if (!$stmt->execute()) {
            return ['error' => 'Timetable query failed: ' . $stmt->error];
        }
        
        $timetable = [];
        $timetableResult = $stmt->get_result();
        while ($row = $timetableResult->fetch_assoc()) {
            $timetable[] = $row;
        }
        
        if (empty($timetable)) {
            return ['error' => 'No timetable entries found for this section'];
        }
        
        return [
            'type' => 'regular',
            'timetable' => $timetable,
            'semester' => $currentSemester,
            'session' => $student['session']
        ];
    } else {
        // Handle irregular students (those who have failed/repeat courses)
        $coursesQuery = "SELECT 
                            c.code,
                            c.title,
                            f.name as faculty_name,
                            co.status,
                            'primary' as status_color
                         FROM student_courses sc
                         JOIN course_offerings co ON sc.course_offering_id = co.id
                         JOIN courses c ON co.course_id = c.id
                         JOIN faculty f ON co.faculty_id = f.id
                         WHERE sc.student_id = (SELECT id FROM students WHERE regno = ?)
                         AND sc.status = 'registered'";
        
        $stmt = $conn->prepare($coursesQuery);
        $stmt->bind_param("s", $regno);
        if (!$stmt->execute()) {
            return ['error' => 'Courses query failed: ' . $stmt->error];
        }
        
        $courses = [];
        $coursesResult = $stmt->get_result();
        while ($row = $coursesResult->fetch_assoc()) {
            $courses[] = $row;
        }
        
        if (empty($courses)) {
            return ['error' => 'No registered courses found for this student'];
        }
        
        return [
            'type' => 'irregular',
            'courses' => $courses
        ];
    }
}

// Handle request
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
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
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Server error: ' . $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}

$conn->close();
?>