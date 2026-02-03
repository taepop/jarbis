import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _apiKeyPref = 'gemini_api_key';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-2.0-flash';

  /// Check if API key is configured
  static Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(_apiKeyPref);
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Save API key
  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, apiKey);
  }

  /// Get API key
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  /// Remove API key
  static Future<void> removeApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPref);
  }

  /// Summarize news for morning briefing
  static Future<String> summarizeNews(String newsContent) async {
    final apiKey = await getApiKey();
    
    if (apiKey == null || apiKey.isEmpty) {
      // Fallback to simple extraction if no API key
      return _simpleSummary(newsContent);
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''You are J.A.R.V.I.S., Tony Stark's AI assistant. 
Create a brief, spoken morning news briefing (under 200 words) from these headlines.
Be conversational, professional, and slightly witty like JARVIS would be.
Start with "Here are today's top stories, sir." and end with a brief closing remark.
Focus on the most significant global news.

News headlines:
$newsContent'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500,
            'topP': 0.9,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_ONLY_HIGH'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH', 
              'threshold': 'BLOCK_ONLY_HIGH'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_ONLY_HIGH'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_ONLY_HIGH'
            }
          ]
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? _simpleSummary(newsContent);
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
        return _simpleSummary(newsContent);
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return _simpleSummary(newsContent);
    }
  }

  /// Test API key validity
  static Future<bool> testApiKey(String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Say "API key is valid" in exactly those words.'}
              ]
            }
          ],
        }),
      ).timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Simple summary fallback when no API key
  static String _simpleSummary(String newsContent) {
    // Extract headlines from the content
    final lines = newsContent.split('\n\n');
    final headlines = <String>[];
    
    for (final line in lines) {
      // Extract title (text before the first period)
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final afterSource = line.substring(colonIndex + 1).trim();
        final periodIndex = afterSource.indexOf('.');
        if (periodIndex > 0) {
          headlines.add(afterSource.substring(0, periodIndex + 1));
        } else {
          headlines.add(afterSource);
        }
      }
    }

    if (headlines.isEmpty) {
      return 'I was unable to retrieve the news at this time, sir.';
    }

    final topHeadlines = headlines.take(5).join(' ');
    return 'Here are today\'s top stories, sir. $topHeadlines That concludes this morning\'s briefing.';
  }
}
