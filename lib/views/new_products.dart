import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:my_member_link/myconfig.dart';

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({Key? key}) : super(key: key);

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  String categoryValue = 'Electronics';
  File? _image;
  bool isLoading = false;

  final categories = [
    'Electronics',
    'Clothing',
    'Home Appliances',
    'Books',
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Product"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _selectFromGallery,
                      child: Container(
                        height: screenHeight * 0.4,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: _image == null
                                ? const AssetImage("assets/images/camera.png")
                                : FileImage(_image!) as ImageProvider,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                        "Product Name", nameController, "Enter Name"),
                    const SizedBox(height: 10),
                    buildTextField("Product Description", descriptionController,
                        "Enter Description",
                        maxLines: 5),
                    const SizedBox(height: 10),
                    buildTextField("Price", priceController, "Enter Price",
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    buildTextField(
                        "Quantity", quantityController, "Enter Quantity",
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      value: categoryValue,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: categories.map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          categoryValue = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    MaterialButton(
                      onPressed: _validateAndSubmit,
                      minWidth: screenWidth,
                      height: 50,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        "Insert",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, String hint,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Future<void> _selectFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await _cropImage();
    }
  }

  Future<void> _cropImage() async {
    if (_image == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    if (croppedFile != null) {
      _image = File(croppedFile.path);
      setState(() {});
    }
  }

  void _validateAndSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an image."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _submitProduct();
  }

  void _submitProduct() async {
    setState(() => isLoading = true);

    final name = nameController.text;
    final description = descriptionController.text;
    final price = priceController.text;
    final quantity = quantityController.text;
    final category = categoryValue;
    final image = base64Encode(_image!.readAsBytesSync());

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/insert_product.php"),
        body: {
          "name": name,
          "description": description,
          "price": price,
          "quantity": quantity,
          "category": category,
          "image": image,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Product inserted successfully!"),
            backgroundColor: Colors.green,
          ));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to insert product."),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Server error. Please try again."),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
