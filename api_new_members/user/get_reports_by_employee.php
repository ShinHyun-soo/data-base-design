<?php
include '../connection.php';

header('Content-Type: application/json');

$employee_id = $_POST['employee_id'];

$query = "
    SELECT r.report_id, r.report_comment, r.inquiry_id, i.issue_name
    FROM report r
    LEFT JOIN delivery_issue_management i ON r.issue_id = i.issue_id
    WHERE r.employee_id = $employee_id
";

$result = $connection->query($query);

if ($result) {
    $reports = $result->fetch_all(MYSQLI_ASSOC);
    echo json_encode(["success" => true, "data" => $reports]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to fetch reports"]);
}
?>
