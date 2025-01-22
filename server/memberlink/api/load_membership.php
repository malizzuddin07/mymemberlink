<?php
// CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Disable error display on the page
error_reporting(E_ALL); // Log all errors
ini_set('display_errors', 0); // Don't display errors on the page

// Log PHP errors to a file (ensure the file is writable by the web server user)
ini_set('log_errors', 1);
ini_set('error_log', '/path/to/your/logs/php_error.log'); // Replace with the actual path

include_once("dbconnect.php");

// Try-catch block to handle errors and exceptions
try {
    // Fetch all membership data
    $sqlfetch = "SELECT * FROM `tbl_memberships` ORDER BY `membership_id` ASC";
    $result = $conn->query($sqlfetch);

    // Prepare response
    if ($result->num_rows > 0) {
        $membershipsarray['memberships'] = array();
        while ($row = $result->fetch_assoc()) {
            $membership = [
                'membership_id' => (string)$row['membership_id'],
                'membership_name' => (string)$row['membership_name'],
                'membership_picture' => (string)$row['membership_picture'],
                'membership_description' => (string)$row['membership_description'],
                'membership_price' => (string)$row['membership_price']
            ];
            array_push($membershipsarray['memberships'], $membership);
        }
        $response = [
            'status' => 'success',
            'data' => $membershipsarray
        ];
    } else {
        $response = [
            'status' => 'empty',
            'message' => 'No memberships found.'
        ];
    }
} catch (Exception $e) {
    // Handle any exceptions and log the error
    $response = [
        'status' => 'error',
        'message' => $e->getMessage()
    ];
    error_log("Error fetching membership data: " . $e->getMessage()); // Log the exception
}

// Send JSON response
header('Content-Type: application/json');
echo json_encode($response, JSON_PRETTY_PRINT); // Use pretty print for easier debugging
exit(); // Ensure no further output is sent
?>
