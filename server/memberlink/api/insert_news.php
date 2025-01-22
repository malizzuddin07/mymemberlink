<?php

// Allow requests from any origin (you can restrict this by replacing '*' with specific origins like 'https://yourdomain.com')
header("Access-Control-Allow-Origin: *");

// Allow specific HTTP methods
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

// Allow specific headers (if needed)
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Ensure the script is handling a POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response = array('status' => 'failed', 'message' => 'Invalid request method.', 'data' => null);
    sendJsonResponse($response);
    die();
}

// Check if the required parameters are provided
if (!isset($_POST['title']) || !isset($_POST['details'])) {
    $response = array('status' => 'failed', 'message' => 'Missing parameters: title or details.', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

// Sanitize inputs
$title = $conn->real_escape_string($_POST['title']);
$details = $conn->real_escape_string($_POST['details']);

// Insert the news into the database
$sqlinsertnews = "INSERT INTO `tbl_news`(`news_title`, `news_details`) VALUES ('$title', '$details')";

if ($conn->query($sqlinsertnews) === TRUE) {
    $response = array('status' => 'success', 'message' => 'News added successfully.', 'data' => null);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'message' => 'Failed to add news. Error: ' . $conn->error, 'data' => null);
    sendJsonResponse($response);
}

// Function to send JSON responses
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
