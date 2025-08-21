
<?php
/**
 * insert_single_admin.php
 * Script to insert a single admin login for CS department
 */

// Database configuration
$db_host = "localhost";
$db_user = "root";
$db_pass = "";
$db_name = "cui_atd";

// Admin data to insert (single record)
$admin = [
    'username' => 'admin@cuiatd.com',  // Change to desired username
    'password' => 'cs123',    // Change to strong password
    'role' => 'department',         // department/registrar/faculty
    'department_id' => 9,           // CS department ID from your schema
    'status' => 'active'            // active/inactive
];

// Create connection
$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);

// Check connection
if ($conn->connect_error) {
    die(json_encode([
        'status' => 'error',
        'message' => 'Database connection failed: ' . $conn->connect_error
    ]));
}

// Check if admin already exists
$check_sql = "SELECT id FROM admin_login WHERE username = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param("s", $admin['username']);
$check_stmt->execute();
$check_stmt->store_result();

if ($check_stmt->num_rows > 1) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Admin username already exists'
    ]);
    exit;
}
$check_stmt->close();

// Hash the password
$hashed_password = password_hash($admin['password'], PASSWORD_DEFAULT);

// Prepare the SQL query
$sql = "INSERT INTO admin_login 
        (username, password, role, department_id, status) 
        VALUES (?, ?, ?, ?, ?)";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Prepare failed: ' . $conn->error
    ]);
    exit;
}

// Bind parameters
$stmt->bind_param("sssis", 
    $admin['username'],
    $hashed_password,
    $admin['role'],
    $admin['department_id'],
    $admin['status']
);

// Execute the query
if ($stmt->execute()) {
    $response = [
        'status' => 'success',
        'message' => 'Admin created successfully',
        'data' => [
            'username' => $admin['username'],
            'role' => $admin['role'],
            'department_id' => $admin['department_id'],
            'status' => $admin['status']
        ]
    ];
} else {
    $response = [
        'status' => 'error',
        'message' => 'Error creating admin: ' . $stmt->error
    ];
}

// Close connections
$stmt->close();
$conn->close();

// Return JSON response
header('Content-Type: application/json');
echo json_encode($response);
?>