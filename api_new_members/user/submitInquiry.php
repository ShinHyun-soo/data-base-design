<?php
include '../connection.php';

header('Content-Type: application/json');

try {
    // 입력 데이터 수집
    $user_id = $_POST['user_id'] ?? null;
    $parcel_id = $_POST['parcel_id'] ?? null;
    $inquiry_comment = $_POST['inquiry_comment'] ?? null;

    // 입력 데이터 유효성 검사
    if (!$user_id || !$parcel_id || !$inquiry_comment) {
        throw new Exception("All fields are required");
    }

    // SQL 쿼리 작성 및 준비
    $query = "INSERT INTO inquiry (user_id, parcel_id, inquiry_comment, problem_state) VALUES (?, ?, ?, 0)";
    $stmt = $connection->prepare($query);

    // prepare가 실패한 경우
    if (!$stmt) {
        throw new Exception("Failed to prepare statement: " . $connection->error);
    }

    // 바인딩 및 실행
    $stmt->bind_param("iis", $user_id, $parcel_id, $inquiry_comment);
    $stmt->execute();

    // 실행 결과 확인
    if ($stmt->affected_rows > 0) {
        echo json_encode(["success" => true, "message" => "Inquiry submitted successfully"]);
    } else {
        throw new Exception("Failed to submit inquiry");
    }

    $stmt->close();
} catch (Exception $e) {
    // 에러 로그 기록
    error_log("Error in submitInquiry.php: " . $e->getMessage());

    // 에러 응답 반환
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
