<?php
include '../connection.php';

header('Content-Type: application/json');
ini_set('display_errors', 0); // HTML 에러 메시지 출력 방지
error_reporting(E_ALL);

$order_id = $_POST['order_id'] ?? null;
$receiver_name = $_POST['receiver_name'] ?? null;
$receiver_phone = $_POST['receiver_phone'] ?? null;
$receiver_address = $_POST['receiver_address'] ?? null;
$receiver_zip_code = $_POST['receiver_zip_code'] ?? null;
$product_id = $_POST['product_id'] ?? null;

if (!$order_id || !$receiver_name || !$receiver_phone || !$receiver_address || !$receiver_zip_code || !$product_id) {
    echo json_encode(["success" => false, "message" => "All fields are required"]);
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

    // current_state가 1인 경우 업데이트 불가
    if ($current_state == 1) {
        echo json_encode(["success" => false, "message" => "Cannot update order"]);
        exit;
    }

    // 이전 제품 ID 가져오기
    $getOrderQuery = "SELECT product_id FROM make_order WHERE order_id = ?";
    $stmt = $connection->prepare($getOrderQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare getOrderQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $stmt->bind_result($previous_product_id);
    $stmt->fetch();
    $stmt->close();

    // 이전 제품 재고 복구
    $restoreStockQuery = "UPDATE product SET stock = stock + 1 WHERE product_id = ?";
    $stmt = $connection->prepare($restoreStockQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare restoreStockQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $previous_product_id);
    $stmt->execute();
    $stmt->close();

    // 새 delivery_id 가져오기
    $zipCheckQuery = "SELECT delivery_id FROM zone WHERE zip_code_start <= ? AND zip_code_end >= ?";
    $stmt = $connection->prepare($zipCheckQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare zipCheckQuery: " . $connection->error);
    }
    $stmt->bind_param("ss", $receiver_zip_code, $receiver_zip_code);
    $stmt->execute();
    $stmt->bind_result($delivery_id);
    $stmt->fetch();
    $stmt->close();

    if (!$delivery_id) {
        throw new Exception("Invalid zip code");
    }

    // delivery_personnel에서 personnel_id 가져오기
    //$getPersonnelQuery = "SELECT personnel_id FROM delivery_personnel WHERE delivery_id = ?";
    $getPersonnelQuery = "SELECT personnel_id FROM delivery_personnel WHERE delivery_id = ? ORDER BY RAND() LIMIT 1";
    $stmt = $connection->prepare($getPersonnelQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare getPersonnelQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $delivery_id);
    $stmt->execute();
    $stmt->bind_result($personnel_id);
    $stmt->fetch();
    $stmt->close();

    if (!$personnel_id) {
        throw new Exception("No personnel assigned for this delivery area");
    }

    // 수신자 업데이트
    $updateReceiverQuery = "UPDATE receiver r
        JOIN make_order o ON r.receiver_id = o.receiver_id
        SET r.receiver_name = ?, r.receiver_phone = ?, r.receiver_address = ?, r.receiver_zip_code = ?
        WHERE o.order_id = ?";
    $stmt = $connection->prepare($updateReceiverQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare updateReceiverQuery: " . $connection->error);
    }
    $stmt->bind_param("ssssi", $receiver_name, $receiver_phone, $receiver_address, $receiver_zip_code, $order_id);
    $stmt->execute();
    $stmt->close();

    // 주문 업데이트
    $updateOrderQuery = "UPDATE make_order SET product_id = ? WHERE order_id = ?";
    $stmt = $connection->prepare($updateOrderQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare updateOrderQuery: " . $connection->error);
    }
    $stmt->bind_param("ii", $product_id, $order_id);
    $stmt->execute();
    $stmt->close();

    // Parcel 테이블 업데이트
    $updateParcelQuery = "UPDATE parcel SET delivery_id = ?, personnel_id = ? WHERE order_id = ?";
    $stmt = $connection->prepare($updateParcelQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare updateParcelQuery: " . $connection->error);
    }
    $stmt->bind_param("iii", $delivery_id, $personnel_id, $order_id);
    $stmt->execute();
    $stmt->close();

    // 새 제품 재고 감소
    $reduceStockQuery = "UPDATE product SET stock = stock - 1 WHERE product_id = ?";
    $stmt = $connection->prepare($reduceStockQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare reduceStockQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $product_id);
    $stmt->execute();
    $stmt->close();

    // **관련된 inquiry 삭제**
    $deleteInquiryQuery = "DELETE FROM inquiry WHERE parcel_id = (SELECT parcel_id FROM parcel WHERE order_id = ?)";
    $stmt = $connection->prepare($deleteInquiryQuery);
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $stmt->close();

    // **관련된 report 삭제**
    $deleteReportQuery = "DELETE FROM report WHERE inquiry_id = (SELECT inquiry_id FROM inquiry WHERE parcel_id = (SELECT parcel_id FROM parcel WHERE order_id = ?))";
    $stmt = $connection->prepare($deleteReportQuery);
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $stmt->close();

    $connection->commit();
    echo json_encode(["success" => true, "message" => "Order, receiver, and parcel updated successfully"]);
} catch (Exception $e) {
    $connection->rollback();
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
