<?php
// Enable CORS
header("Access-Control-Allow-Origin: *"); // Allows requests from all origins (you can restrict this to specific origins if needed)
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE"); // Allowed methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allowed headers

// Handle pre-flight OPTIONS request (this is important for CORS)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit; // Respond to OPTIONS requests and exit
}

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

$newsid = $_POST['newsid'];
$title = $_POST['title'];
$details = $_POST['details'];

// Prepare the SQL statement using a prepared statement to prevent SQL injection
$stmt = $conn->prepare("UPDATE tbl_news SET news_title = ?, news_details = ? WHERE news_id = ?");
$stmt->bind_param("ssi", $title, $details, $newsid);

// Execute the prepared statement
if ($stmt->execute()) {
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
} else {
    // Log the error for debugging purposes
    error_log("SQL Error: " . $stmt->error);
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
