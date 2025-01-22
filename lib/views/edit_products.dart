import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:my_member_link/myconfig.dart';

class EditProductScreen extends StatefulWidget {
  final Map product;
  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  File? image;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.product['product_name']);
    descriptionController =
        TextEditingController(text: widget.product['product_description']);
    priceController =
        TextEditingController(text: widget.product['product_price']);
    quantityController =
        TextEditingController(text: widget.product['product_quantity']);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
      );
      setState(() {
        image = File(croppedFile!.path);
      });
    }
  }

  Future<void> updateProduct() async {
    setState(() => isLoading = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${MyConfig.servername}/memberlink/api/edit_products.php"),
      );
      // Add product details as fields
      request.fields['product_id'] = widget.product['product_id'];
      request.fields['name'] = nameController.text.trim();
      request.fields['description'] = descriptionController.text.trim();
      request.fields['price'] = priceController.text.trim();
      request.fields['quantity'] = quantityController.text.trim();

      // Add image if a new one is selected
      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath("image", image!.path));
      }

      // Send request
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await http.Response.fromStream(response);
        var responseData = responseBody.body;

        if (responseData.contains('"status":"success"')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product updated successfully!")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update product.")),
          );
        }
      } else {
        showErrorSnackbar(
            "Error: Server returned status ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackbar("An unexpected error occurred: $e");
      print("Error Details: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
            const SizedBox(height: 10),
            image == null
                ? widget.product['product_image'] != null
                    ? Image.network(
                        "${MyConfig.servername}/${widget.product['product_image']}",
                        height: 150,
                        width: 150,
                      )
                    : const Text("No image available.")
                : Image.file(image!, height: 150, width: 150),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Change Image"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: updateProduct,
                    child: const Text("Update Product"),
                  ),
          ],
        ),
      ),
    );
  }
}
