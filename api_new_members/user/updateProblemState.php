<?php
include '../connection.php';

header('Content-Type: application/json');

// report 삭제 및 inquiry 테이블 problem_state 업데이트
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $report_id = $_POST['report_id'];
    $inquiry_id = $_POST['inquiry_id']; // inquiry_id도 받아옵니다

    // 트랜잭션 시작
    $connection->begin_transaction();

    try {
        // report 삭제
        $deleteReportQuery = "DELETE FROM report WHERE report_id = ?";
        $stmt = $connection->prepare($deleteReportQuery);
        $stmt->bind_param("i", $report_id);
        $stmt->execute();

        // inquiry 테이블의 problem_state 업데이트
        $updateInquiryQuery = "UPDATE inquiry SET problem_state = 0 WHERE inquiry_id = ?";
        $stmt = $connection->prepare($updateInquiryQuery);
        $stmt->bind_param("i", $inquiry_id);
        $stmt->execute();

        // 트랜잭션 커밋
        $connection->commit();
        
        echo json_encode(["success" => true, "message" => "Report deleted and problem_state updated successfully."]);
    } catch (Exception $e) {
        // 오류 발생 시 롤백
        $connection->rollback();
        echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
    }
}
?>
