<?php
// CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include_once("dbconnect.php");

// Disable error display to prevent unexpected output in JSON
error_reporting(0);
ini_set('display_errors', 0);

try {
    // Query to fetch payment records
    $sql = "SELECT membership_name, purchase_date, payment_amount, payment_status FROM tbl_payments ORDER BY id ASC";
    $result = $conn->query($sql);

    if ($result && $result->num_rows > 0) {
        $payments = [];
        while ($row = $result->fetch_assoc()) {
            $payments[] = [
                'membership_name' => $row['membership_name'],
                'purchase_date' => $row['purchase_date'],
                'payment_amount' => $row['payment_amount'],
                'payment_status' => $row['payment_status']
            ];
        }

        $response = [
            'status' => 'success',
            'data' => $payments
        ];
    } else {
        $response = [
            'status' => 'empty',
            'message' => 'No payment records found.'
        ];
    }
} catch (Exception $e) {
    $response = [
        'status' => 'error',
        'message' => $e->getMessage()
    ];
}

// Send JSON response
header('Content-Type: application/json');
echo json_encode($response);

$conn->close();
?>