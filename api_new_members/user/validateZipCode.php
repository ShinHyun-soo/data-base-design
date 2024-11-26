<?php
// 응답의 콘텐츠 타입을 JSON으로 설정
header('Content-Type: application/json');

// 데이터베이스 연결 파일 포함
include '../connection.php';

// POST 요청에서 우편번호(zip code)를 가져옴
$zip_code = $_POST['zip_code'] ?? null;

// 우편번호가 제공되었는지 확인
if (!$zip_code) {
    // 제공되지 않았다면 실패를 나타내는 JSON 응답 반환
    echo json_encode(["success" => false, "message" => "Zip code is required"]);
    exit; // 스크립트 종료
}

// zone 테이블에서 우편번호가 zip_code_start와 zip_code_end 범위 내에 있는 delivery_id를 선택하는 SQL 문 준비
$sql = "SELECT delivery_id FROM zone WHERE zip_code_start <= ? AND zip_code_end >= ?";
$stmt = $connection->prepare($sql);

// SQL 문에 우편번호를 매개변수로 바인딩
$stmt->bind_param("ss", $zip_code, $zip_code);

// SQL 문 실행
$stmt->execute();

// 실행된 문장의 결과를 가져옴
$result = $stmt->get_result();

// 반환된 행(row)이 있는지 확인
if ($result->num_rows > 0) {
    // 있다면, 우편번호가 유효함을 나타내는 JSON 응답 반환
    echo json_encode(["success" => true, "message" => "Valid zip code"]);
} else {
    // 없다면, 우편번호가 유효하지 않음을 나타내는 JSON 응답 반환
    echo json_encode(["success" => false, "message" => "Invalid zip code"]);
}

// 준비된 문장 닫기
$stmt->close();

// 데이터베이스 연결 닫기
$connection->close();
?>
