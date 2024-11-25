<?php
include '../connection.php';

header('Content-Type: application/json');

// 제품 리스트와 stock 정보 가져오기
$sql = "SELECT p.product_id, p.product_name, p.factory_id, f.factory_name, p.stock
        FROM product p
        JOIN factory f ON p.factory_id = f.factory_id";
$result = $connection->query($sql);

if ($result->num_rows > 0) {
    $products = [];
    while ($row = $result->fetch_assoc()) {
        $products[] = $row;
    }
    echo json_encode(['success' => true, 'data' => $products]);
} else {
    echo json_encode(['success' => false, 'message' => 'No products found']);
}

$connection->close();
?>
