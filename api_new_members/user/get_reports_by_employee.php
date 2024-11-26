<?php
// 데이터베이스 연결 파일 포함
include '../connection.php';

// 응답의 콘텐츠 타입을 JSON으로 설정
header('Content-Type: application/json');

// POST 요청에서 employee_id를 가져옴
$employee_id = $_POST['employee_id'];

// 특정 직원의 보고서를 가져오는 SQL 쿼리 작성
$query = "
    SELECT r.report_id, r.report_comment, r.inquiry_id, i.issue_name
    FROM report r
    LEFT JOIN delivery_issue_management i ON r.issue_id = i.issue_id
    WHERE r.employee_id = $employee_id
";

// 쿼리 실행
$result = $connection->query($query);

// 쿼리 실행 결과 확인
if ($result) {
    // 결과를 연관 배열 형태로 모두 가져옴
    $reports = $result->fetch_all(MYSQLI_ASSOC);
    // 성공적으로 데이터를 반환하는 JSON 응답 반환
    echo json_encode(["success" => true, "data" => $reports]);
} else {
    // 보고서 가져오기에 실패했음을 나타내는 JSON 응답 반환
    echo json_encode(["success" => false, "message" => "Failed to fetch reports"]);
}
?>
