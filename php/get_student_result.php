<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json");

$host = 'localhost';
$dbname = 'cui_atd';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $regno = $_GET['regno'] ?? '';

    if (empty($regno)) {
        echo json_encode(['status' => 'error', 'message' => 'Missing regno']);
        exit;
    }

    $stmt = $pdo->prepare("SELECT id FROM students WHERE regno = ?");
    $stmt->execute([$regno]);
    $student = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$student) {
        echo json_encode(['status' => 'error', 'message' => 'Student not found']);
        exit;
    }

    $studentId = $student['id'];

    $sql = "
        SELECT 
            c.code AS course_code,
            c.title AS course_title,
            c.credit_hours,
            fg.grade,
            fg.grade_points,
            co.semester
        FROM 
            student_courses sc
        JOIN 
            course_offerings co ON sc.course_offering_id = co.id
        JOIN 
            courses c ON co.course_id = c.id
        LEFT JOIN 
            final_grades fg ON fg.student_course_id = sc.id
        WHERE 
            sc.student_id = ?
        ORDER BY 
            co.semester, c.code
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([$studentId]);
    $courses = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'status' => 'success',
        'regno' => $regno,
        'courses' => $courses
    ]);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
