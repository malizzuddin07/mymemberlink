<?php
include_once("db_connect.php");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $product_id = $_POST['product_id'];

    $query = "DELETE FROM tbl_products WHERE product_id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $product_id);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Product deleted successfully"]);
    } else {
        echo json_encode(["status" => "failure", "message" => "Failed to delete product"]);
    }

    $stmt->close();
    $conn->close();
}
?>
