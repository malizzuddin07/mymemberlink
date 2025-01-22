// news_model.dart

class News {
  final int newsId; // Ensure this is an integer
  final String newsTitle;
  final String newsDetails;
  final DateTime newsDate;

  News({
    required this.newsId,
    required this.newsTitle,
    required this.newsDetails,
    required this.newsDate,
  });

  // Factory constructor to create a News object from JSON
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      // Ensure news_id is treated as an integer
      newsId: json['news_id'] is int
          ? json['news_id']
          : int.tryParse(json['news_id'].toString()) ??
              0, // Safe parsing of news_id
      newsTitle: json['news_title'] ?? '',
      newsDetails: json['news_details'] ?? '',
      newsDate: DateTime.parse(
          json['news_date']), // Ensure news_date is parsed as DateTime
    );
  }

  // Method to convert News object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'news_id': newsId,
      'news_title': newsTitle,
      'news_details': newsDetails,
      'news_date':
          newsDate.toIso8601String(), // Convert DateTime to string for JSON
    };
  }
}
