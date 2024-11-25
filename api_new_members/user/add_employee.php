<?php
//직원 추가 관련 php
header('Content-Type: application/json');
include '../connection.php';

$user_id = $_POST['user_id'];

// 디버깅 로그 추가
error_log("Received user_id: " . $user_id);

// employee 테이블에 user_id 추가
$sql = "INSERT INTO employee (user_id) VALUES ('$user_id')";

if ($connection->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "Employee added successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to add employee"]);
    error_log("MySQL error: " . $connection->error); // MySQL 오류 로그 추가
}

$connection->close();
?>
