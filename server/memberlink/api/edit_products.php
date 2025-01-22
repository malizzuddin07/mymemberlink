<?php
include_once("db_connect.php");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $product_id = $_POST['product_id'];
    $name = $_POST['name'];
    $description = $_POST['description'];
    $price = $_POST['price'];
    $quantity = $_POST['quantity'];

    // Handle image upload
    if (isset($_FILES['image']['name'])) {
        $image = $_FILES['image']['name'];
        $target_dir = "uploads/";
        $target_file = $target_dir . basename($image);
        move_uploaded_file($_FILES['image']['tmp_name'], $target_file);

        $query = "UPDATE tbl_products SET product_name = ?, product_description = ?, product_price = ?, product_quantity = ?, product_image = ? WHERE product_id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ssdssi", $name, $description, $price, $quantity, $target_file, $product_id);
    } else {
        $query = "UPDATE tbl_products SET product_name = ?, product_description = ?, product_price = ?, product_quantity = ? WHERE product_id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ssdsi", $name, $description, $price, $quantity, $product_id);
    }

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Product updated successfully"]);
    } else {
        echo json_encode(["status" => "failure", "message" => "Failed to update product"]);
    }

    $stmt->close();
    $conn->close();
}
?>
