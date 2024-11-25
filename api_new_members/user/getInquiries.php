<?php
include '../connection.php';

header('Content-Type: application/json');

try {
    $query = "
        SELECT 
            i.inquiry_id,
            i.inquiry_comment,
            i.problem_state,
            u.user_name,
            r.receiver_name,
            p.product_name
        FROM inquiry i
        LEFT JOIN user u ON i.user_id = u.user_id
        LEFT JOIN parcel pc ON i.parcel_id = pc.parcel_id
        LEFT JOIN make_order mo ON pc.order_id = mo.order_id
        LEFT JOIN receiver r ON mo.receiver_id = r.receiver_id
        LEFT JOIN product p ON mo.product_id = p.product_id
        WHERE i.problem_state = 0
    ";

    $result = $connection->query($query);

    if ($result) {
        $inquiries = $result->fetch_all(MYSQLI_ASSOC);
        echo json_encode(["success" => true, "data" => $inquiries]);
    } else {
        throw new Exception("Failed to fetch inquiries");
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
