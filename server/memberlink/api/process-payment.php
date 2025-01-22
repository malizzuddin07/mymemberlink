<?php
// CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include_once("dbconnect.php");

// Retrieve JSON data from the POST request body
$input = json_decode(file_get_contents('php://input'), true);

// Ensure required fields are present
if (isset($input['amount'], $input['userId'], $input['status'])) {
    $amount = $conn->real_escape_string($input['amount']);
    $user_id = $conn->real_escape_string($input['userId']);
    $status = $conn->real_escape_string($input['status']);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Required data is missing.",
    ]);
    exit;
}

// Query to get the latest payment entry for the user and the matching amount
$sql = "SELECT * FROM tbl_payments 
        WHERE user_id = '$user_id' 
        AND payment_amount = '$amount' 
        ORDER BY id DESC LIMIT 1";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $payment = $result->fetch_assoc();
    $payment_id = $payment['id'];

    // Update the status of the selected payment entry
    $update_sql = "UPDATE tbl_payments 
                   SET payment_status = '$status' 
                   WHERE id = '$payment_id'";

    if ($conn->query($update_sql) === TRUE) {
        echo json_encode([
            "success" => true,
            "message" => "Payment status updated to '$status'.",
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Error updating payment status: " . $conn->error,
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "No matching payment entry found.",
    ]);
}

$conn->close();
?>