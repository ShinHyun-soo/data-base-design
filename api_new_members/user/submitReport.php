<?php
include '../connection.php';

header('Content-Type: application/json');

$employee_id = $_POST['employee_id'] ?? null;
$issue_id = $_POST['issue_id'] ?? null;
$report_comment = $_POST['report_comment'] ?? null;
$inquiry_id = $_POST['inquiry_id'] ?? null;

if (!$employee_id || !$issue_id || !$report_comment || !$inquiry_id) {
    echo json_encode(["success" => false, "message" => "All fields are required"]);
    exit;
}

try {
    // Report 테이블에 데이터 삽입
    $query = "INSERT INTO report (employee_id, issue_id, report_comment, inquiry_id) VALUES (?, ?, ?, ?)";
    $stmt = $connection->prepare($query);
    $stmt->bind_param("iisi", $employee_id, $issue_id, $report_comment, $inquiry_id);
    $stmt->execute();

    // Inquiry 상태 업데이트
    $updateQuery = "UPDATE inquiry SET problem_state = 1 WHERE inquiry_id = ?";
    $stmt = $connection->prepare($updateQuery);
    $stmt->bind_param("i", $inquiry_id);
    $stmt->execute();

    echo json_encode(["success" => true, "message" => "Report submitted successfully"]);
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
}
?>
