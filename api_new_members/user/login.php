<?php
include '../connection.php';

$userEmail = $_POST['user_email'];
$userPassword = md5($_POST['user_password']); //보안을 위해서 md5로 감싸기

$sqlQuery = "SELECT * FROM user WHERE user_email = '$userEmail' AND user_password = '$userPassword'";

$resultQuery = $connection -> query($sqlQuery);

if($resultQuery ->num_rows > 0){ 

    $userRecord = array();
    while($rowFound = $resultQuery->fetch_assoc()){
        $userRecord[] = $rowFound;
    }
    echo json_encode(
        array(
            "success" => true,
            "userData" => $userRecord[0]
        )); //fat arrow: 값을 할당할 때 사용
}
else{
    echo json_encode(array("success" => false));
}