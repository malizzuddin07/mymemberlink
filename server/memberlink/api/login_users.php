<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$email = $_POST['email'];
$password = $_POST['password'];

$sqllogin = "SELECT `admin_email`, `admin_pass` FROM `tbl_admins` WHERE `admin_email` = '$email'";
$result = $conn->query($sqllogin);
if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    if (password_verify($password, $row['admin_pass'])) {
        $response = array('status' => 'success', 'data' => null);
    } else {
        $response = array('status' => 'failed', 'data' => null);
    }
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    // Allow CORS
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, Authorization");

    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>