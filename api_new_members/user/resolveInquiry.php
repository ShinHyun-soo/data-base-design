<?php
include '../connection.php';

header('Content-Type: application/json');

$inquiry_id = $_POST['inquiry_id'] ?? null;

if (!$inquiry_id) {
    echo json_encode(["success" => false, "message" => "Inquiry ID is required"]);
    exit;
}

try {
    $query = "UPDATE inquiry SET problem_state = 1 WHERE inquiry_id = ?";
    $stmt = $connection->prepare($query);
    if (!$stmt) {
        throw new Exception("Failed to prepare statement: " . $connection->error);
    }

    $stmt->bind_param("i", $inquiry_id);
    $stmt->execute();

    if ($stmt->affected_rows > 0) {
        echo json_encode(["success" => true, "message" => "Inquiry resolved successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to resolve inquiry"]);
    }

    $stmt->close();
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
