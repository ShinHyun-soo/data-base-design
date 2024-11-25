<?php
include '../connection.php';

// 입력 데이터
$receiver_name = $_POST['receiver_name'] ?? null;
$receiver_phone = $_POST['receiver_phone'] ?? null;
$receiver_address = $_POST['receiver_address'] ?? null;
$receiver_zip_code = $_POST['receiver_zip_code'] ?? null;
$product_id = $_POST['product_id'] ?? null;
$user_id = $_POST['user_id'] ?? null; // user_id 추가

// 필수 데이터 검증
if (!$receiver_name || !$receiver_phone || !$receiver_address || !$receiver_zip_code || !$product_id || !$user_id) {
    echo json_encode(["success" => false, "message" => "All fields are required"]);
    exit;
}

// 입력값 형식 검증 (추가)
if (!preg_match('/^\d{5}$/', $receiver_zip_code)) {
    echo json_encode(["success" => false, "message" => "Invalid zip code format"]);
    exit;
}

if (!preg_match('/^\d{3}-\d{4}-\d{4}$/', $receiver_phone)) {
    echo json_encode(["success" => false, "message" => "Invalid phone number format"]);
    exit;
}

$connection->begin_transaction();

try {
    // delivery_id 가져오기
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

    // Debug: delivery_id 확인
    error_log("Delivery ID: $delivery_id");

    // delivery_personnel에서 personnel_id 가져오기
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

    // Debug: personnel_id 확인
    error_log("Personnel ID: $personnel_id");

    // 수신자 추가
    $addReceiverQuery = "INSERT INTO receiver (receiver_name, receiver_phone, receiver_address, receiver_zip_code) VALUES (?, ?, ?, ?)";
    $stmt = $connection->prepare($addReceiverQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare addReceiverQuery: " . $connection->error);
    }
    $stmt->bind_param("ssss", $receiver_name, $receiver_phone, $receiver_address, $receiver_zip_code);
    $stmt->execute();
    $receiver_id = $stmt->insert_id;
    $stmt->close();

    // Debug: receiver_id 확인
    error_log("Receiver ID: $receiver_id");

    // 주문 추가 (user_id 반영)
    $addOrderQuery = "INSERT INTO make_order (order_date, availability_date, user_id, receiver_id, product_id) VALUES (CURDATE(), CURDATE() + INTERVAL 1 DAY, ?, ?, ?)";
    $stmt = $connection->prepare($addOrderQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare addOrderQuery: " . $connection->error);
    }
    $stmt->bind_param("iii", $user_id, $receiver_id, $product_id);
    $stmt->execute();
    $order_id = $stmt->insert_id;
    $stmt->close();

    // Debug: order_id 확인
    error_log("Order ID: $order_id");

    // parcel 추가
    $addParcelQuery = "INSERT INTO parcel (order_id, delivery_id, personnel_id) VALUES (?, ?, ?)";
    $stmt = $connection->prepare($addParcelQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare addParcelQuery: " . $connection->error);
    }
    $stmt->bind_param("iii", $order_id, $delivery_id, $personnel_id);
    $stmt->execute();
    $stmt->close();

    // Debug: parcel 추가 성공 메시지
    error_log("Parcel added for Order ID: $order_id");

    // 재고 감소
    $reduceStockQuery = "UPDATE product SET stock = stock - 1 WHERE product_id = ?";
    $stmt = $connection->prepare($reduceStockQuery);
    if (!$stmt) {
        throw new Exception("Failed to prepare reduceStockQuery: " . $connection->error);
    }
    $stmt->bind_param("i", $product_id);
    $stmt->execute();
    $stmt->close();

    // Debug: 재고 감소 확인
    error_log("Stock updated for Product ID: $product_id");

    $connection->commit();
    echo json_encode(["success" => true, "message" => "Order and parcel added successfully"]);
} catch (Exception $e) {
    $connection->rollback();
    error_log("Error: " . $e->getMessage()); // 오류 로그
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
