<?php
include_once("db_connect.php");

$page = isset($_GET['pageno']) ? intval($_GET['pageno']) : 1;
$records_per_page = 10;
$offset = ($page - 1) * $records_per_page;

$query = "SELECT * FROM tbl_products LIMIT $offset, $records_per_page";
$result = $conn->query($query);

if ($result->num_rows > 0) {
    $products = [];
    while ($row = $result->fetch_assoc()) {
        $products[] = $row;
    }
    echo json_encode([
        "status" => "success",
        "data" => $products,
        "numofpage" => ceil($conn->query("SELECT COUNT(*) AS total FROM tbl_products")->fetch_assoc()['total'] / $records_per_page)
    ]);
} else {
    echo json_encode(["status" => "failure", "message" => "No products found"]);
}

$conn->close();
?>
