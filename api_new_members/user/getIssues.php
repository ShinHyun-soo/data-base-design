<?php
include '../connection.php';

header('Content-Type: application/json');

// 모든 Issue 가져오기
$query = "SELECT issue_id, issue_name FROM delivery_issue_management";

$result = $connection->query($query);

if ($result) {
    $issues = $result->fetch_all(MYSQLI_ASSOC);
    echo json_encode(["success" => true, "data" => $issues]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to fetch issues"]);
}
?>
