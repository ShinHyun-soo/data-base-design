<?php
header('Content-Type: application/json'); // JSON 형식의 응답을 설정

$myServer = "localhost";
$user = "root"; // 데이터베이스 사용자명
$password = ""; // 데이터베이스 비밀번호
$database = "test"; // 데이터베이스 이름

// MySQL 데이터베이스 연결 시도
$connection = new mysqli($myServer, $user, $password, $database);

// 연결 실패 시 JSON 형식으로 오류 반환
if ($connection->connect_error) {
    die(json_encode(array("success" => false, "error" => "데이터베이스 연결 실패: " . $connection->connect_error)));
}

// 성공 메시지는 출력하지 않음 - JSON 형식 유지
