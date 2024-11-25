<?php
//order_page에서 수신자와 물건을 받는 php
header('Content-Type: application/json');
include '../connection.php';

$zip_code = $_POST['zip_code'] ?? null;

if (!$zip_code) {
    echo json_encode(["success" => false, "message" => "Zip code is required"]);
    exit;
}

$sql = "SELECT delivery_id FROM zone WHERE zip_code_start <= ? AND zip_code_end >= ?";
$stmt = $connection->prepare($sql);
$stmt->bind_param("ss", $zip_code, $zip_code);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    echo json_encode(["success" => true, "message" => "Valid zip code"]);
} else {
    echo json_encode(["success" => false, "message" => "Invalid zip code"]);
}

$stmt->close();
$connection->close();
?>
