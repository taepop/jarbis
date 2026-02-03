import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/news_model.dart';
import 'gemini_service.dart';

class NewsService {
  static const List<String> _rssFeeds = [
    'https://feeds.bbci.co.uk/news/world/rss.xml',
    'https://rss.nytimes.com/services/xml/rss/nyt/World.xml',
    'https://feeds.npr.org/1004/rss.xml', // NPR World
  ];

  static const String _cachedNewsKey = 'cached_news';
  static const String _cachedBriefingKey = 'cached_briefing';

  /// Fetch news from RSS feeds
  static Future<List<NewsItem>> fetchNews({int maxItems = 10}) async {
    final List<NewsItem> allNews = [];

    for (final feedUrl in _rssFeeds) {
      try {
        final items = await _fetchRssFeed(feedUrl);
        allNews.addAll(items);
      } catch (e) {
        print('Error fetching feed $feedUrl: $e');
        // Continue with other feeds
      }
    }

    // Sort by date and take top items
    allNews.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
    final topNews = allNews.take(maxItems).toList();

    // Cache news
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cachedNewsKey,
      jsonEncode(topNews.map((n) => n.toJson()).toList()),
    );

    return topNews;
  }

  /// Fetch single RSS feed
  static Future<List<NewsItem>> _fetchRssFeed(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'JarvisAlarmApp/1.0'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final feed = RssFeed.parse(response.body);
      final source = feed.title ?? 'Unknown Source';

      return feed.items?.map((item) {
        return NewsItem(
          title: item.title ?? '',
          description: _cleanDescription(item.description ?? ''),
          link: item.link ?? '',
          source: source,
          publishedDate: item.pubDate ?? DateTime.now(),
        );
      }).toList() ?? [];
    }
    throw Exception('Failed to fetch RSS feed: ${response.statusCode}');
  }

  /// Clean HTML tags from description
  static String _cleanDescription(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Get AI-summarized news briefing
  static Future<String> getNewsBriefing() async {
    try {
      final news = await fetchNews(maxItems: 8);
      
      if (news.isEmpty) {
        return await _getCachedBriefing() ?? 
            'Unable to fetch current news at this time.';
      }

      // Create news summary text for AI
      final newsText = news.map((item) => 
        '${item.source}: ${item.title}. ${item.description}'
      ).join('\n\n');

      // Use Gemini to summarize
      final briefing = await GeminiService.summarizeNews(newsText);
      
      // Cache the briefing
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedBriefingKey, briefing);
      
      return briefing;
    } catch (e) {
      print('Error getting news briefing: $e');
      return await _getCachedBriefing() ??
          'Unable to fetch current news at this time.';
    }
  }

  /// Get cached news
  static Future<List<NewsItem>> getCachedNews() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedNewsKey);
    if (cached != null) {
      final List<dynamic> json = jsonDecode(cached);
      return json.map((j) => NewsItem.fromJson(j)).toList();
    }
    return [];
  }

  /// Get cached briefing
  static Future<String?> _getCachedBriefing() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cachedBriefingKey);
  }
}
