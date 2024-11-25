<?php
include '../connection.php';

header('Content-Type: application/json');

// 입력 데이터 확인
$inquiry_id = $_POST['inquiry_id'] ?? null; // 수정할 문의 ID
$new_comment = $_POST['inquiry_comment'] ?? null; // 새로운 문의 내용

if (!$inquiry_id || !$new_comment) {
    echo json_encode(["success" => false, "message" => "Inquiry ID and new comment are required"]);
    exit;
}

try {
    // 문제 상태 확인 (해결된 문의는 수정 불가)
    $checkQuery = "SELECT problem_state FROM inquiry WHERE inquiry_id = ?";
    $stmt = $connection->prepare($checkQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare checkQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $inquiry_id);
    $stmt->execute();
    $stmt->bind_result($problem_state);
    $stmt->fetch();
    $stmt->close();

    if ($problem_state == 1) {
        echo json_encode(["success" => false, "message" => "Cannot modify a resolved inquiry"]);
        exit;
    }

    // 문의 내용 업데이트
    $updateQuery = "UPDATE inquiry SET inquiry_comment = ? WHERE inquiry_id = ?";
    $stmt = $connection->prepare($updateQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare updateQuery: " . $connection->error);
    }
    $stmt->bind_param("si", $new_comment, $inquiry_id);
    $stmt->execute();
    $stmt->close();

    // report 테이블의 report_comment도 업데이트
    $updateReportQuery = "UPDATE report SET report_comment = ? WHERE inquiry_id = ?";
    $stmt = $connection->prepare($updateReportQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare updateReportQuery: " . $connection->error);
    }
    $stmt->bind_param("si", $new_comment, $inquiry_id);
    $stmt->execute();
    $stmt->close();

    echo json_encode(["success" => true, "message" => "Inquiry and Report updated successfully"]);
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
