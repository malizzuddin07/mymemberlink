import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_member_link/models/news.dart';
import 'package:http/http.dart' as http;
import 'package:my_member_link/myconfig.dart';

class EditNewsScreen extends StatefulWidget {
  final News news;
  const EditNewsScreen({super.key, required this.news});

  @override
  State<EditNewsScreen> createState() => _EditNewsState();
}

class _EditNewsState extends State<EditNewsScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  bool isUpdating = false; // For loading indicator

  @override
  void initState() {
    super.initState();
    titleController.text = widget.news.newsTitle ?? '';
    detailsController.text = widget.news.newsDetails ?? '';
  }

  late double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Newsletter"),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              isUpdating
                  ? const CircularProgressIndicator() // Show a loading indicator while updating
                  : MaterialButton(
                      elevation: 10,
                      onPressed: onUpdateNewsDialog,
                      minWidth: screenWidth,
                      height: 50,
                      color: Theme.of(context).colorScheme.secondary,
                      child: const Text(
                        "Update News",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void onUpdateNewsDialog() {
    if (titleController.text.isEmpty || detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Title and details cannot be empty."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update News?"),
          content: const Text("Are you sure you want to update this news?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                updateNews();
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  void updateNews() async {
    setState(() {
      isUpdating = true;
    });

    String title = titleController.text.trim();
    String details = detailsController.text.trim();

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/update_news.php"),
        body: {
          "newsid": widget.news.newsId.toString(),
          "title": title,
          "details": details,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Update Success"),
            backgroundColor: Colors.green,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Update Failed"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error updating news. Please try again later."),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // Catch the error, show the snackbar, and print the error for debugging
      showErrorSnackbar("An unexpected error occurred: $e");
      print("Error Details: $e"); // Log the error details for debugging
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

// Helper method to show the error snackbar
  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }
}
