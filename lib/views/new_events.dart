import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_member_link/myconfig.dart';

class NewEventScreen extends StatefulWidget {
  const NewEventScreen({super.key});

  @override
  State<NewEventScreen> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen> {
  String startDateTime = "", endDateTime = "";
  String eventtypevalue = 'Conference';
  var selectedStartDateTime, selectedEndDateTime;

  final items = [
    'Conference',
    'Exhibition',
    'Seminar',
    'Hackathon',
  ];

  late double screenWidth, screenHeight;
  File? _image;

  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Event"),
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
                        "Event Title", titleController, "Enter Title"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        buildDateTimeSelector("Start Date", true),
                        buildDateTimeSelector("End Date", false),
                      ],
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                        "Event Location", locationController, "Enter Location"),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      value: eventtypevalue,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: items.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          eventtypevalue = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    buildTextField("Event Description", descriptionController,
                        "Enter Description",
                        maxLines: 5),
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
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
      maxLines: maxLines,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Widget buildDateTimeSelector(String label, bool isStart) {
    return GestureDetector(
      onTap: () => _selectDateTime(isStart),
      child: Column(
        children: [
          Text(label),
          Text(isStart ? startDateTime : endDateTime),
        ],
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

  void _selectDateTime(bool isStart) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        final formattedDateTime =
            DateFormat('dd-MM-yyyy hh:mm a').format(selectedDateTime);

        if (isStart) {
          startDateTime = formattedDateTime;
          selectedStartDateTime = selectedDateTime;
        } else {
          endDateTime = formattedDateTime;
          selectedEndDateTime = selectedDateTime;
        }
        setState(() {});
      }
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
    if (startDateTime.isEmpty || endDateTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select start and end dates."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _submitEvent();
  }

  void _submitEvent() async {
    setState(() => isLoading = true);

    final title = titleController.text;
    final location = locationController.text;
    final description = descriptionController.text;
    final start = selectedStartDateTime.toString();
    final end = selectedEndDateTime.toString();
    final image = base64Encode(_image!.readAsBytesSync());

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/insert_event.php"),
        body: {
          "title": title,
          "location": location,
          "description": description,
          "eventtype": eventtypevalue,
          "start": start,
          "end": end,
          "image": image,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Event inserted successfully!"),
            backgroundColor: Colors.green,
          ));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to insert event."),
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
