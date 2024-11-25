<?php
include '../connection.php';

try {
    // 현재 날짜를 기준으로 order_date와 availability_date를 비교하여 상태 갱신
    $query = "UPDATE parcel p
              JOIN make_order o ON p.order_id = o.order_id
              SET p.current_state = 1
              WHERE o.availability_date <= CURDATE() AND p.current_state = 0";

    $result = $connection->query($query);

    if ($result) {
        echo json_encode(["success" => true, "message" => "States updated successfully"]);
    } else {
        throw new Exception("Failed to update states: " . $connection->error);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
