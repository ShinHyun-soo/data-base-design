<?php
include '../connection.php';

$order_id = $_POST['order_id'] ?? null;
$receiver_zip_code = $_POST['receiver_zip_code'] ?? null;

if (!$order_id || !$receiver_zip_code) {
    echo json_encode(["success" => false, "message" => "Order ID and Receiver Zip Code are required"]);
    exit;
}

$connection->begin_transaction();

try {
    // delivery_id 가져오기
    $zipCheckQuery = "SELECT delivery_id FROM zone WHERE zip_code_start <= ? AND zip_code_end >= ?";
    $stmt = $connection->prepare($zipCheckQuery);
    $stmt->bind_param("ss", $receiver_zip_code, $receiver_zip_code);
    $stmt->execute();
    $stmt->bind_result($delivery_id);
    $stmt->fetch();
    $stmt->close();

    if (!$delivery_id) {
        throw new Exception("Invalid zip code");
    }

    // personnel_id 가져오기
    //$getPersonnelQuery = "SELECT personnel_id FROM delivery_personnel WHERE delivery_id = ?";
    $getPersonnelQuery = "SELECT personnel_id FROM delivery_personnel WHERE delivery_id = ? ORDER BY RAND() LIMIT 1";
    $stmt = $connection->prepare($getPersonnelQuery);
    $stmt->bind_param("i", $delivery_id);
    $stmt->execute();
    $stmt->bind_result($personnel_id);
    $stmt->fetch();
    $stmt->close();

    if (!$personnel_id) {
        throw new Exception("No personnel assigned for this delivery area");
    }

    // parcel 업데이트
    $updateParcelQuery = "UPDATE parcel SET personnel_id = ? WHERE order_id = ?";
    $stmt = $connection->prepare($updateParcelQuery);
    $stmt->bind_param("ii", $personnel_id, $order_id);
    $stmt->execute();
    $stmt->close();

    $connection->commit();
    echo json_encode(["success" => true, "message" => "Parcel personnel updated successfully"]);
} catch (Exception $e) {
    $connection->rollback();
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
