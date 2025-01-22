<?php
include_once("dbconnect.php");

// Check if required POST parameters are provided
if (
    isset($_POST['user_id']) &&
    isset($_POST['membership_name']) &&
    isset($_POST['purchase_date']) &&
    isset($_POST['payment_amount']) &&
    isset($_POST['payment_status']) 
) {
    // Retrieve POST data
    $user_id = $conn->real_escape_string($_POST['user_id']);
    $membership_name = $conn->real_escape_string($_POST['membership_name']);
    $purchase_date = $conn->real_escape_string($_POST['purchase_date']);
    $payment_amount = $conn->real_escape_string($_POST['payment_amount']);
    $payment_status = $conn->real_escape_string($_POST['payment_status']);
    
    // SQL query to insert data into tbl_payments
    $sql = "INSERT INTO tbl_payments (user_id, membership_name, purchase_date, payment_amount, payment_status) 
            VALUES ('$user_id', '$membership_name', '$purchase_date', '$payment_amount', '$payment_status')";

    // Execute the query
    if ($conn->query($sql) === TRUE) {
        echo json_encode([
            "status" => "success",
            "message" => "Payment entry created successfully"
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Error: " . $conn->error
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Required parameters are missing"
    ]);
}

// Close the connection
$conn->close();
?>