<?php
include '../connection.php';

header('Content-Type: application/json');

$user_id = $_POST['user_id'] ?? null;

if (!$user_id) {
    echo json_encode(["success" => false, "message" => "User ID is required"]);
    exit;
}

try {
    // 현재 날짜를 구하기 위해 `CURDATE()` 사용
    $query = "
        SELECT 
            o.order_id,
            r.receiver_name,
            r.receiver_phone,
            r.receiver_address,
            r.receiver_zip_code,
            p.product_name,
            o.order_date,
            o.availability_date,
            pa.current_state
        FROM make_order o
        JOIN receiver r ON o.receiver_id = r.receiver_id
        JOIN product p ON o.product_id = p.product_id
        LEFT JOIN parcel pa ON o.order_id = pa.order_id
        WHERE o.user_id = ? 
        AND pa.current_state = 1
        AND DATEDIFF(CURDATE(), o.availability_date) <= 15
    ";

    $stmt = $connection->prepare($query);
    if (!$stmt) {
        throw new Exception("Failed to prepare query: " . $connection->error);
    }

    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $orders = [];
    while ($row = $result->fetch_assoc()) {
        $orders[] = $row;
    }

    echo json_encode(["success" => true, "data" => $orders]);

    $stmt->close();
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
