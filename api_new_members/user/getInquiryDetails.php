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
            i.inquiry_id,
            i.inquiry_comment,
            i.problem_state,
            r.report_comment  -- report_comment 추가
        FROM inquiry i
        JOIN parcel p ON i.parcel_id = p.parcel_id
        LEFT JOIN report r ON i.inquiry_id = r.inquiry_id  -- report 테이블 JOIN
        WHERE p.order_id = ?
    ";

    $stmt = $connection->prepare($query);
    if (!$stmt) {
        throw new Exception("Failed to prepare statement: " . $connection->error);
    }

    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $data = $result->fetch_assoc();
        echo json_encode(["success" => true, "data" => $data]);
    } else {
        echo json_encode(["success" => false, "message" => "No inquiry found for this order"]);
    }

    $stmt->close();
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
