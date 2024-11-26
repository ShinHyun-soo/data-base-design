<?php
// 데이터베이스 연결 파일 포함
include '../connection.php';

try {
    // 현재 날짜(CURDATE())를 기준으로 order_date와 availability_date를 비교하여 상태를 갱신하는 쿼리 작성
    $query = "UPDATE parcel p
              JOIN make_order o ON p.order_id = o.order_id
              SET p.current_state = 1
              WHERE o.availability_date <= CURDATE() AND p.current_state = 0";

    // 쿼리를 실행
    $result = $connection->query($query);

    // 쿼리 실행 결과 확인
    if ($result) {
        // 성공적으로 상태가 갱신되었음을 나타내는 JSON 응답 반환
        echo json_encode(["success" => true, "message" => "States updated successfully"]);
    } else {
        // 쿼리 실행이 실패하면 예외 발생
        throw new Exception("Failed to update states: " . $connection->error);
    }
} catch (Exception $e) {
    // 예외가 발생하면 실패 메시지를 포함한 JSON 응답 반환
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
