<?php
include '../connection.php';

header('Content-Type: application/json');

// 사용자 ID를 가져옵니다.
$user_id = $_POST['user_id'] ?? null;

if (!$user_id) {
    echo json_encode(["success" => false, "message" => "User ID is required"]);
    exit;
}

try {
    // 사용자가 선택할 수 있는 Parcel을 가져오는 쿼리
    $query = "
    SELECT 
        p.parcel_id, 
        p.current_state, 
        o.order_id,
        COALESCE(r.receiver_name, 'Unknown Receiver') AS receiver_name, 
        COALESCE(pr.product_name, 'Unknown Product') AS product_name
    FROM 
        parcel p
    JOIN 
        make_order o ON p.order_id = o.order_id
    JOIN 
        receiver r ON o.receiver_id = r.receiver_id
    JOIN 
        product pr ON o.product_id = pr.product_id
    WHERE 
        o.user_id = ? AND NOT EXISTS (
            SELECT 1 FROM inquiry i WHERE i.parcel_id = p.parcel_id
        )
";

    
    $stmt = $connection->prepare($query);
    if (!$stmt) {
        throw new Exception("Failed to prepare statement: " . $connection->error);
    }

    $stmt->bind_param("i", $user_id);
    $stmt->execute();

    $result = $stmt->get_result();
    if (!$result) {
        throw new Exception("Failed to execute query: " . $stmt->error);
    }

    $parcels = [];
    while ($row = $result->fetch_assoc()) {
        // Parcel 데이터 포맷팅
        $parcels[] = [
            "parcel_id" => $row['parcel_id'],
            "current_state" => $row['current_state'],
            "order_id" => $row['order_id'],
            "description" => $row['receiver_name'] . " - " . $row['product_name'] // 수신자 이름 - 제품 이름
        ];
    }

    $stmt->close();

    echo json_encode(["success" => true, "data" => $parcels]);
} catch (Exception $e) {
    // 디버그 로그 기록
    error_log("Error fetching parcels: " . $e->getMessage());

    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
