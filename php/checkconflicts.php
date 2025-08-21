<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include './connection/connection.php';

$data = json_decode(file_get_contents("php://input"), true);
$section_ids = $data['sections'] ?? [];

if (empty($section_ids)) {
    echo json_encode(['error' => 'No sections provided']);
    exit;
}

try {
    // Get timetable for all selected sections
    $placeholders = implode(',', array_fill(0, count($section_ids), '?'));
    $query = "
        SELECT 
            t.id,
            c.code as course_code,
            s.id as section_id,
            s.name as section_name,
            ts.day,
            ts.start_time,
            ts.end_time,
            t.room
        FROM timetable t
        JOIN time_slots ts ON t.time_slot_id = ts.id
        JOIN course_offerings co ON t.course_offering_id = co.id
        JOIN courses c ON co.course_id = c.id
        JOIN sections s ON co.section_id = s.id
        WHERE co.id IN (
            SELECT course_offering_id 
            FROM student_courses 
            WHERE section_id IN ($placeholders)
        )
        ORDER BY ts.day, ts.start_time
    ";
    
    $stmt = $conn->prepare($query);
    $types = str_repeat('i', count($section_ids));
    $stmt->bind_param($types, ...$section_ids);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $timetable = [];
    while ($row = $result->fetch_assoc()) {
        $timetable[] = $row;
    }
    
    // Check for conflicts
    $conflicts = [];
    $checked = [];
    
    foreach ($timetable as $i => $slot1) {
        foreach ($timetable as $j => $slot2) {
            if ($i >= $j) continue; // Avoid duplicate checks
            
            $key = $i.'_'.$j;
            if (in_array($key, $checked)) continue;
            $checked[] = $key;
            
            if ($slot1['day'] == $slot2['day'] && 
                time_overlap($slot1['start_time'], $slot1['end_time'], 
                             $slot2['start_time'], $slot2['end_time'])) {
                
                if (!isset($conflicts[$slot1['course_code']])) {
                    $conflicts[$slot1['course_code']] = [];
                }
                if (!isset($conflicts[$slot2['course_code']])) {
                    $conflicts[$slot2['course_code']] = [];
                }
                
                $conflicts[$slot1['course_code']][] = $slot2['section_id'];
                $conflicts[$slot2['course_code']][] = $slot1['section_id'];
            }
        }
    }
    
    echo json_encode([
        'timetable' => $timetable,
        'conflicts' => $conflicts
    ]);
    
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}

function time_overlap($start1, $end1, $start2, $end2) {
    $start1 = strtotime($start1);
    $end1 = strtotime($end1);
    $start2 = strtotime($start2);
    $end2 = strtotime($end2);
    
    return ($start1 < $end2) && ($end1 > $start2);
}

$conn->close();
?>