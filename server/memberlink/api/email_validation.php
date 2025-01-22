<?php
include_once("dbconnect.php");
$email = $_POST['email'];

// Query to check if email already exists
$sqlcheck = "SELECT * FROM tbl_admins WHERE admin_email = '$email'";
$result = $conn->query($sqlcheck);

if ($result->num_rows > 0) {
    // Email already exists
    $response = array('status' => 'exists');
} else {
    // Email does not exist
    $response = array('status' => 'not_exists');
}
sendJsonResponse($response);

function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
