<?php
include '../connection.php';

header('Content-Type: application/json');

$user_id = $_POST['user_id'] ?? null;

if (!$user_id) {
    echo json_encode(["success" => false, "message" => "User ID is required"]);
    exit;
}

try {
    $query = "SELECT employee_id FROM employee WHERE user_id = ?";
    $stmt = $connection->prepare($query);
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $stmt->bind_result($employee_id);
    $stmt->fetch();
    $stmt->close();

    if ($employee_id) {
        echo json_encode(["success" => true, "data" => ["employee_id" => $employee_id]]);
    } else {
        echo json_encode(["success" => false, "message" => "Employee not found"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
