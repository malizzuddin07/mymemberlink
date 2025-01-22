import 'package:flutter/material.dart';
import 'package:my_member_link/models/news.dart';
import 'package:intl/intl.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;
  final df = DateFormat('dd/MM/yyyy hh:mm a');

  NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("News Detail"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.newsTitle,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, height: 1.5),
            ),
            const SizedBox(height: 10),
            Text(
              df.format(DateTime.parse(news.newsDate.toString())),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              news.newsDetails,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
