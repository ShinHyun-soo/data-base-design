<?php
// 데이터베이스 연결 파일 포함
include '../connection.php';

// 응답의 콘텐츠 타입을 JSON으로 설정
header('Content-Type: application/json');

// POST 요청에서 order_id를 가져옴
$order_id = $_POST['order_id'] ?? null;

// order_id가 제공되었는지 확인
if (!$order_id) {
    // 제공되지 않았다면 실패를 나타내는 JSON 응답 반환
    echo json_encode(["success" => false, "message" => "Order ID is required"]);
    exit; // 스크립트 종료
}

try {
    // 주문 상세 정보를 가져오는 SQL 쿼리 작성
    $query = "
        SELECT 
            r.receiver_name,
            r.receiver_phone,
            r.receiver_address,
            r.receiver_zip_code,
            p.product_name,
            o.order_date,
            o.availability_date,
            u.user_name AS user_name, -- user 테이블에서 user_name 가져오기
            dc.company_name AS company_name, -- delivery_company에서 company_name 가져오기
            dp.personnel_name AS personnel_name, -- delivery_personnel에서 personnel_name 가져오기
            pa.current_state -- parcel 테이블에서 current_state 가져오기
        FROM make_order o
        JOIN receiver r ON o.receiver_id = r.receiver_id
        JOIN product p ON o.product_id = p.product_id
        JOIN user u ON o.user_id = u.user_id -- user 테이블 조인
        LEFT JOIN parcel pa ON o.order_id = pa.order_id
        LEFT JOIN delivery_personnel dp ON pa.personnel_id = dp.personnel_id
        LEFT JOIN delivery_company dc ON dp.company_id = dc.company_id
        WHERE o.order_id = ?
    ";

    // 쿼리 준비
    $stmt = $connection->prepare($query);
    if (!$stmt) {
        // 쿼리 준비가 실패하면 예외 발생
        throw new Exception("Failed to prepare query: " . $connection->error);
    }

    // order_id를 매개변수로 바인딩
    $stmt->bind_param("i", $order_id);
    // 쿼리 실행
    $stmt->execute();
    // 실행 결과 가져오기
    $result = $stmt->get_result();

    // 결과에 행이 있는지 확인
    if ($result->num_rows > 0) {
        // 행이 있다면 데이터를 가져와 JSON 응답으로 반환
        $data = $result->fetch_assoc();
        echo json_encode(["success" => true, "data" => $data]);
    } else {
        // 행이 없다면 해당 주문에 대한 세부 정보를 찾을 수 없음을 나타내는 JSON 응답 반환
        echo json_encode(["success" => false, "message" => "No details found for this order"]);
    }

    // 준비된 문장 닫기
    $stmt->close();
} catch (Exception $e) {
    // 예외가 발생하면 실패 메시지를 포함한 JSON 응답 반환
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
