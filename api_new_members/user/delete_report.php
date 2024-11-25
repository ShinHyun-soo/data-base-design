<?php
include '../connection.php';

header('Content-Type: application/json');

// Get report_id and inquiry_id from the request
$report_id = $_POST['report_id'];
$inquiry_id = $_POST['inquiry_id'];

// SQL query to delete the report and update problem_state in the inquiry table
$query = "
    UPDATE inquiry 
    SET problem_state = 0 
    WHERE inquiry_id = $inquiry_id;
    
    DELETE FROM report 
    WHERE report_id = $report_id;
";

if ($connection->multi_query($query)) {
    echo json_encode(["success" => true, "message" => "Report deleted and problem_state updated"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to delete report or update problem_state"]);
}
?>
