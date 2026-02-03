class NewsItem {
  final String title;
  final String description;
  final String link;
  final String source;
  final DateTime publishedDate;

  NewsItem({
    required this.title,
    required this.description,
    required this.link,
    required this.source,
    required this.publishedDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'link': link,
    'source': source,
    'publishedDate': publishedDate.toIso8601String(),
  };

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      source: json['source'] ?? '',
      publishedDate: DateTime.parse(json['publishedDate']),
    );
  }

  @override
  String toString() {
    return 'NewsItem(title: $title, source: $source)';
  }
}
