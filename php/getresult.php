<?php
// Database connection parameters
$host = 'localhost';
$dbname = 'cui_atd';
$username = 'root';
$password = '';

try {
    // Create a PDO connection
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Prepare the query to get student ID first
    $regno = 'FA21-BCS-154';
    $stmt = $pdo->prepare("SELECT id FROM students WHERE regno = ?");
    $stmt->execute([$regno]);
    $student = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$student) {
        echo "Student with regno $regno not found.";
        exit;
    }

    $studentId = $student['id'];

    // Query to get all courses taken by the student with grades
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

    // Display the results
    echo "<h2>Courses Studied by $regno</h2>";
    echo "<table border='1'>";
    echo "<tr><th>Semester</th><th>Course Code</th><th>Course Title</th><th>Credit Hours</th><th>Grade</th><th>Grade Points</th></tr>";
    
    foreach ($courses as $course) {
        echo "<tr>";
        echo "<td>{$course['semester']}</td>";
        echo "<td>{$course['course_code']}</td>";
        echo "<td>{$course['course_title']}</td>";
        echo "<td>{$course['credit_hours']}</td>";
        echo "<td>{$course['grade']}</td>";
        echo "<td>{$course['grade_points']}</td>";
        echo "</tr>";
    }
    
    echo "</table>";

} catch (PDOException $e) {
    die("Database error: " . $e->getMessage());
}
?>