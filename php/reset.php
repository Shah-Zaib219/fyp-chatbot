<?php
// Database connection
$host = "localhost";
$user = "root";
$password = "";
$database = "cui_atd";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die("Database connection failed: " . $conn->connect_error);
}

// Hash for password "123"
$newPasswordHash = password_hash('123', PASSWORD_BCRYPT);

// Update all student passwords
$updateStudents = $conn->prepare("UPDATE student_login SET password = ?");
$updateStudents->bind_param("s", $newPasswordHash);
$updateStudents->execute();
$studentCount = $updateStudents->affected_rows;
$updateStudents->close();

// Update all admin passwords
$updateAdmins = $conn->prepare("UPDATE admin_login SET password = ?");
$updateAdmins->bind_param("s", $newPasswordHash);
$updateAdmins->execute();
$adminCount = $updateAdmins->affected_rows;
$updateAdmins->close();

// Output results
echo "Password reset completed successfully:\n";
echo "- Updated $studentCount student accounts\n";
echo "- Updated $adminCount admin accounts\n";

$conn->close();
?>