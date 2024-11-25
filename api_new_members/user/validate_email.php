<?php
header('Content-Type: application/json'); // JSON 형식의 응답을 보냄
include '../connection.php';

$userEmail = $_POST['user_email'];

// 준비된 문을 사용하여 SQL 인젝션 방지
$sqlQuery = "SELECT * FROM user WHERE user_email = ?";
$stmt = $connection->prepare($sqlQuery);
$stmt->bind_param("s", $userEmail);
$stmt->execute();
$resultQuery = $stmt->get_result();

if ($resultQuery->num_rows > 0) { // 이메일이 중복됨
    echo json_encode(array("exitEmail" => true));
} else { // 이메일이 중복되지 않음
    echo json_encode(array("exitEmail" => false));
}

$stmt->close();
$connection->close();
?>
