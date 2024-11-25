<?php
header('Content-Type: application/json');
include '../connection.php';

$userName = $_POST['user_name'];
$userEmail = $_POST['user_email'];
$userPassword = md5($_POST['user_password']);
$userPhone = $_POST['user_phone'];
$userAddress = $_POST['user_address'];
$userType = $_POST['user_type'];

$sql = "INSERT INTO user (user_name, user_email, user_password, user_phone, user_address, user_type) 
        VALUES ('$userName', '$userEmail', '$userPassword', '$userPhone', '$userAddress', '$userType')";

if ($connection->query($sql) === TRUE) {
    $user_id = $connection->insert_id; // 새로 추가된 user_id 가져오기
    echo json_encode(["success" => true, "user_id" => $user_id]);
} else {
    echo json_encode(["success" => false, "message" => "Error occurred"]);
}

$connection->close();
?>
