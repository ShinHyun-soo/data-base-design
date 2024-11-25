<?php
include '../connection.php';

header('Content-Type: application/json');

// 직원이 처리할 문의 가져오기
try {
    $query = "
        SELECT 
            i.inquiry_id,
            i.inquiry_comment,
            r.receiver_name,
            p.product_name,
            pa.parcel_id
        FROM inquiry i
        JOIN parcel pa ON i.parcel_id = pa.parcel_id
        JOIN make_order o ON pa.order_id = o.order_id
        JOIN receiver r ON o.receiver_id = r.receiver_id
        JOIN product p ON o.product_id = p.product_id
        WHERE i.problem_state = 0
    ";

    $stmt = $connection->prepare($query);
    if (!$stmt) {
        throw new Exception("Failed to prepare statement: " . $connection->error);
    }

    $stmt->execute();
    $result = $stmt->get_result();

    $inquiries = [];
    while ($row = $result->fetch_assoc()) {
        $inquiries[] = $row;
    }

    echo json_encode(["success" => true, "data" => $inquiries]);
    $stmt->close();
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
