import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_member_link/models/news.dart';
import 'package:my_member_link/myconfig.dart';
import 'package:my_member_link/views/edit_news.dart';
import 'package:my_member_link/views/mydrawer.dart';
import 'package:my_member_link/views/new_news.dart';
import 'package:my_member_link/views/newsdetail_screen.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<News> newsList = [];
  List<News> filteredNews = [];
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  int numofpage = 1;
  int curpage = 1;
  String query = "";
  late double screenWidth, screenHeight;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadNewsData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Newsletter"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadNewsData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredNews.isEmpty
                  ? const Center(
                      child: Text("No news available."),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: filteredNews.length,
                        itemBuilder: (context, index) {
                          return _buildNewsCard(index);
                        },
                      ),
                    ),
          _buildPaginationControls(),
        ],
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (content) => const NewNewsScreen()),
          );
          loadNewsData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            query = value.toLowerCase();
            filteredNews = newsList
                .where((news) =>
                    news.newsTitle.toLowerCase().contains(query) ||
                    news.newsDetails.toLowerCase().contains(query))
                .toList();
          });
        },
        decoration: InputDecoration(
          hintText: "Search news...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(int index) {
    return Card(
      child: ListTile(
        onLongPress: () {
          deleteDialog(index); // Show delete confirmation dialog on long press
        },
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              truncateString(filteredNews[index].newsTitle, 30),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              df.format(
                DateTime.parse(filteredNews[index].newsDate.toString()),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        subtitle: Text(
          truncateString(filteredNews[index].newsDetails, 100),
          textAlign: TextAlign.justify,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button for navigating to the Edit News screen
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                navigateToEditNews(index); // Trigger navigate to Edit News
              },
            ),
            // Delete button for removing the news item
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                deleteDialog(index); // Trigger delete dialog
              },
            ),
          ],
        ),
        // Navigate to News Detail on tap
        onTap: () {
          navigateToNewsDetail(index); // Navigate to News Detail Screen
        },
      ),
    );
  }

  void navigateToNewsDetail(int index) {
    News selectedNews = filteredNews[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(news: selectedNews),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: curpage > 1
                ? () {
                    setState(() {
                      curpage--;
                    });
                    loadNewsData();
                  }
                : null,
            child: const Text("Previous"),
          ),
          Text("Page $curpage of $numofpage"),
          ElevatedButton(
            onPressed: curpage < numofpage
                ? () {
                    setState(() {
                      curpage++;
                    });
                    loadNewsData();
                  }
                : null,
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  void deleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Delete \"${truncateString(filteredNews[index].newsTitle, 20)}\"",
            style: const TextStyle(fontSize: 18),
          ),
          content: const Text("Are you sure you want to delete this news?"),
          actions: [
            TextButton(
              onPressed: () {
                deleteNews(index); // Call the delete function
                Navigator.pop(context);
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

  String truncateString(String str, int length) {
    return (str.length > length) ? "${str.substring(0, length)}..." : str;
  }

  // Navigate to the Edit News screen
  void navigateToEditNews(int index) async {
    News selectedNews = filteredNews[index];
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNewsScreen(news: selectedNews),
      ),
    );
    loadNewsData();
  }

  void deleteNews(int index) async {
    String newsId = newsList[index].newsId.toString();

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/delete_news.php"),
        body: {"newsid": newsId},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          setState(() {
            newsList.removeAt(index); // Remove the deleted item from the list
            filteredNews = List.from(newsList); // Update the filtered list
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("News deleted successfully."),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to delete news."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        showErrorSnackbar("Error connecting to server: ${response.statusCode}");
      }
    } catch (e) {
      // Show snackbar and print the error details
      showErrorSnackbar("An unexpected error occurred: $e");
      print("Error Details: $e"); // Log the error details
    }
  }

  void loadNewsData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(
            Uri.parse(
                "${MyConfig.servername}/memberlink/api/load_news.php?pageno=$curpage"),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['status'] == "success") {
          setState(() {
            newsList = (data['data']['news'] as List)
                .map<News>((item) => News.fromJson(item))
                .toList();
            filteredNews = List.from(newsList);
            numofpage = int.parse(data['numofpage'].toString());
          });
        } else {
          showErrorSnackbar(data['message']);
        }
      } else {
        showErrorSnackbar("Error connecting to server: ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackbar("An unexpected error occurred: $e");
      print("Error Details: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
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
}
