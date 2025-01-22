import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_member_link/myconfig.dart';

class NewNewsScreen extends StatefulWidget {
  const NewNewsScreen({super.key});

  @override
  State<NewNewsScreen> createState() => _NewNewsScreenState();
}

class _NewNewsScreenState extends State<NewNewsScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  bool isLoading = false; // Loading state

  late double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Newsletter"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                hintText: "News Title",
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: screenHeight * 0.7,
              child: TextField(
                controller: detailsController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: "News Details",
                ),
                maxLines: screenHeight ~/ 35,
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator() // Show a loading indicator while submitting
                : MaterialButton(
                    elevation: 10,
                    onPressed: onInsertNewsDialog,
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
    );
  }

  void onInsertNewsDialog() {
    if (titleController.text.trim().isEmpty ||
        detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter both title and details."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: const Text("Insert this newsletter?"),
          content: const Text("Are you sure you want to add this news?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                insertNews();
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void insertNews() async {
    setState(() {
      isLoading = true;
    });

    String title = titleController.text.trim();
    String details = detailsController.text.trim();

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/insert_news.php"),
        body: {"title": title, "details": details},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Insert Success"),
            backgroundColor: Colors.green,
          ));
          Navigator.pop(context); // Return to the previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Insert Failed"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error: Unable to connect to the server."),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // Enhanced error handling
      showErrorSnackbar("An unexpected error occurred: $e");
      print("Error Details: $e"); // Log the error details for debugging
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// Function to show the error in a snackbar
  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
