<?php
include_once("db_connect.php");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
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
    } else {
        $image = null;
    }

    $query = "INSERT INTO tbl_products (product_name, product_description, product_price, product_quantity, product_image)
              VALUES (?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("ssdss", $name, $description, $price, $quantity, $target_file);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Product added successfully"]);
    } else {
        echo json_encode(["status" => "failure", "message" => "Failed to add product"]);
    }

    $stmt->close();
    $conn->close();
}
?>
