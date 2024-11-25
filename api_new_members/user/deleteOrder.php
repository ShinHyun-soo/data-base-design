<?php
include '../connection.php';

$order_id = $_POST['order_id'] ?? null;

if (!$order_id) {
    echo json_encode(["success" => false, "message" => "Order ID is required"]);
    exit;
}

$connection->begin_transaction();

try {
    // current_state 확인
    $checkStateQuery = "SELECT current_state FROM parcel WHERE order_id = ?";
    $stmt = $connection->prepare($checkStateQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare checkStateQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $stmt->bind_result($current_state);
    $stmt->fetch();
    $stmt->close();

    // current_state가 1인 경우 삭제 불가
    if ($current_state == 1) {
        echo json_encode(["success" => false, "message" => "Cannot delete order"]);
        exit;
    }

    // **관련된 inquiry 삭제**
    $deleteInquiryQuery = "DELETE FROM inquiry WHERE parcel_id = (SELECT parcel_id FROM parcel WHERE order_id = ?)";
    $stmt = $connection->prepare($deleteInquiryQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare deleteInquiryQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $stmt->close();

    // **관련된 report 삭제** - inquiry가 삭제되었으므로 관련된 report도 삭제
    $deleteReportQuery = "DELETE FROM report WHERE inquiry_id = (SELECT inquiry_id FROM inquiry WHERE parcel_id = (SELECT parcel_id FROM parcel WHERE order_id = ?))";
    $stmt = $connection->prepare($deleteReportQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare deleteReportQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $stmt->close();

    // 주문에 연결된 product_id 가져오기
    $getProductQuery = "SELECT product_id FROM make_order WHERE order_id = ?";
    $stmt = $connection->prepare($getProductQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare getProductQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $stmt->bind_result($product_id);
    $stmt->fetch();
    $stmt->close();

    // 제품 재고 복구
    $restoreStockQuery = "UPDATE product SET stock = stock + 1 WHERE product_id = ?";
    $stmt = $connection->prepare($restoreStockQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare restoreStockQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $product_id);
    $stmt->execute();
    $stmt->close();
    

    // 주문에 연결된 receiver_id 가져오기
    $getReceiverQuery = "SELECT receiver_id FROM make_order WHERE order_id = ?";
    $stmt = $connection->prepare($getReceiverQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare getReceiverQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $stmt->bind_result($receiver_id);
    $stmt->fetch();
    $stmt->close();

    // Parcel 데이터 삭제
    $deleteParcelQuery = "DELETE FROM parcel WHERE order_id = ?";
    $stmt = $connection->prepare($deleteParcelQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare deleteParcelQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $stmt->close();
    
    // 주문 삭제
    $deleteOrderQuery = "DELETE FROM make_order WHERE order_id = ?";
    $stmt = $connection->prepare($deleteOrderQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare deleteOrderQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $stmt->close();

    // 다른 주문에서 참조되지 않는 경우, receiver 삭제
    $checkReceiverQuery = "SELECT COUNT(*) AS count FROM make_order WHERE receiver_id = ?";
    $stmt = $connection->prepare($checkReceiverQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare checkReceiverQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $receiver_id);
    $stmt->execute();
    $stmt->bind_result($count);
    $stmt->fetch();
    $stmt->close();

    if ($count == 0) {
        $deleteReceiverQuery = "DELETE FROM receiver WHERE receiver_id = ?";
        $stmt = $connection->prepare($deleteReceiverQuery);
        if (!$stmt) {
            throw new Exception("Failed to prepare deleteReceiverQuery: " . $connection->error);
        }
        $stmt->bind_param("i", $receiver_id);
        $stmt->execute();
        $stmt->close();
    }

    $connection->commit();
    echo json_encode(["success" => true, "message" => "Order and parcel deleted successfully"]);
} catch (Exception $e) {
    $connection->rollback();
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
