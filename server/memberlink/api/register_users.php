<?php
// Add CORS headers
header("Access-Control-Allow-Origin: *");  // Allows requests from any origin. Replace '*' with a specific domain if needed for security.
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");  // Allow the methods you need (POST, GET, etc.)
header("Access-Control-Allow-Headers: Content-Type, Authorization");  // Allow headers that might be sent (like content-type or authorization)

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    // If the request is an OPTIONS request, return a successful response
    http_response_code(200);
    exit();
}

if (!isset($_POST['email']) || !isset($_POST['password'])) {
    $response = array('status' => 'failed', 'message' => 'Email or password not set');
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

$email = $_POST['email'];
$password = password_hash($_POST['password'], PASSWORD_DEFAULT);

$sqlinsert = $conn->prepare("INSERT INTO `tbl_admins`(`admin_email`, `admin_pass`) VALUES (?, ?)");
$sqlinsert->bind_param("ss", $email, $password);

if ($sqlinsert->execute()) {
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'message' => 'Failed to insert data');
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
