<?php

// Allow CORS for all domains or set specific domain instead of '*'
header("Access-Control-Allow-Origin: *"); // Use specific domain instead of * for better security, e.g., "http://example.com"
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Allow methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow headers like Content-Type, Authorization

// Handle pre-flight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit();
}

include_once("dbconnect.php");

// Validate and sanitize the page number input
$page = isset($_GET['pageno']) ? filter_var($_GET['pageno'], FILTER_VALIDATE_INT) : 1;
$page = max(1, $page); // Ensure page number is at least 1

$results_per_page = 10; // Number of results per page
$offset = ($page - 1) * $results_per_page;

// Count total rows in the database for pagination
$sqltotal = "SELECT COUNT(*) FROM `tbl_news`";
$total_result = $conn->query($sqltotal);

if (!$total_result) {
    $response = array(
        'status' => 'failed',
        'message' => 'Failed to retrieve total number of rows.',
        'data' => null
    );
    sendJsonResponse($response);
    die();
}

$total_rows = $total_result->fetch_array()[0];
$total_pages = ceil($total_rows / $results_per_page);

// Fetch the news data with limit and offset for pagination
$sqlloadnews = $conn->prepare("SELECT * FROM `tbl_news` ORDER BY `news_date` DESC LIMIT ? OFFSET ?");
$sqlloadnews->bind_param("ii", $results_per_page, $offset);
$sqlloadnews->execute();
$result = $sqlloadnews->get_result();

if ($result->num_rows > 0) {
    $newsarray['news'] = array();
    while ($row = $result->fetch_assoc()) {
        $news = array();
        $news['news_id'] = $row['news_id'];
        $news['news_title'] = $row['news_title'];
        $news['news_details'] = $row['news_details'];
        $news['news_date'] = $row['news_date'];
        array_push($newsarray['news'], $news);
    }
    $response = array(
        'status' => 'success',
        'message' => 'News retrieved successfully.',
        'data' => $newsarray,
        'numofpage' => $total_pages,
        'current_page' => $page,
        'numberofresult' => $total_rows
    );
    sendJsonResponse($response);
} else {
    $response = array(
        'status' => 'failed',
        'message' => 'No news found for the requested page.',
        'data' => null
    );
    sendJsonResponse($response);
}

// Function to send JSON responses
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>
