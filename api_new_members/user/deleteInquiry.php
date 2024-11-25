<?php
include '../connection.php';

header('Content-Type: application/json');

// 입력 데이터
$inquiry_id = $_POST['inquiry_id'] ?? null;

if (!$inquiry_id) {
    echo json_encode(["success" => false, "message" => "Inquiry ID is required"]);
    exit;
}

try {
    // 문제 상태 확인
    $checkStateQuery = "SELECT problem_state FROM inquiry WHERE inquiry_id = ?";
    $stmt = $connection->prepare($checkStateQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare checkStateQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $inquiry_id);
    $stmt->execute();
    $stmt->bind_result($problem_state);
    $stmt->fetch();
    $stmt->close();

    // 문제 상태가 1이면 삭제 불가
    if ($problem_state == 1) {
        echo json_encode(["success" => false, "message" => "Cannot delete resolved inquiry"]);
        exit;
    }

    // inquiry 삭제
    $deleteInquiryQuery = "DELETE FROM inquiry WHERE inquiry_id = ?";
    $stmt = $connection->prepare($deleteInquiryQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare deleteInquiryQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $inquiry_id);
    $stmt->execute();
    $stmt->close();

    // 관련된 report도 삭제
    $deleteReportQuery = "DELETE FROM report WHERE inquiry_id = ?";
    $stmt = $connection->prepare($deleteReportQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare deleteReportQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $inquiry_id);
    $stmt->execute();
    $stmt->close();

    echo json_encode(["success" => true, "message" => "Inquiry and related report deleted successfully"]);
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
