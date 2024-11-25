<?php
include '../connection.php';

header('Content-Type: application/json');

// 보고서 수정
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $report_id = $_POST['report_id'];
    $report_comment = $_POST['report_comment']; // 수정된 comment

    // report 테이블의 report_comment 수정
    $updateReportQuery = "UPDATE report SET report_comment = ? WHERE report_id = ?";
    $stmt = $connection->prepare($updateReportQuery);
    $stmt->bind_param("si", $report_comment, $report_id);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Report updated successfully."]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to update report."]);
    }
}
?>
