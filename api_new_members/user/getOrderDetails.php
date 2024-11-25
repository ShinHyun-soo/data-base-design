<?php
include '../connection.php';

header('Content-Type: application/json');

$order_id = $_POST['order_id'] ?? null;

if (!$order_id) {
    echo json_encode(["success" => false, "message" => "Order ID is required"]);
    exit;
}

try {
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

    $stmt = $connection->prepare($query);
    if (!$stmt) {
        throw new Exception("Failed to prepare query: " . $connection->error);
    }

    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $data = $result->fetch_assoc();
        echo json_encode(["success" => true, "data" => $data]);
    } else {
        echo json_encode(["success" => false, "message" => "No details found for this order"]);
    }

    $stmt->close();
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
