<?php
// Allow access from any origin (for testing purposes, be more restrictive in production)
header("Access-Control-Allow-Origin: *");
// Allow the necessary HTTP methods
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, DELETE");
// Allow the necessary headers
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight requests for CORS
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

// Ensure the script is handling a POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response = array('status' => 'failed', 'message' => 'Invalid request method.', 'data' => null);
    sendJsonResponse($response);
    die();
}

// Check if the required parameter is provided
if (!isset($_POST['newsid'])) {
    $response = array('status' => 'failed', 'message' => 'Missing parameter: newsid.', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once('dbconnect.php');

// Sanitize input
$newsid = $_POST['newsid'];

// Use prepared statement for security (SQL injection prevention)
$sqldeletenews = "DELETE FROM `tbl_news` WHERE `news_id` = ?";
$stmt = $conn->prepare($sqldeletenews);

// Check if the statement was prepared successfully
if ($stmt === false) {
    $response = array('status' => 'failed', 'message' => 'Failed to prepare the statement: ' . $conn->error, 'data' => null);
    sendJsonResponse($response);
    die();
}

// Bind the parameter to the statement
$stmt->bind_param("i", $newsid);

// Execute the statement
if ($stmt->execute()) {
    $response = array('status' => 'success', 'message' => 'News deleted successfully.', 'data' => null);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'message' => 'Failed to delete news. ' . $stmt->error, 'data' => null);
    sendJsonResponse($response);
}

// Close the statement and connection
$stmt->close();
$conn->close();

// Function to send JSON responses
function sendJsonResponse($sentArray) {
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
