import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PrivacyService {
  static const String _privacyPolicyUrl =
      'https://docs.google.com/document/d/1GGN1zc9PyD62BLHKO86DUAkBv_THPzauoy9kx1GcUKU/export?format=html';

  static const String _cacheFileName = 'privacy_policy.html';

  // Stiahni Privacy Policy HTML alebo vráť cached verziu
  static Future<String> getPrivacyPolicyHtml() async {
    try {
      print('Attempting to download privacy policy HTML...');
      final response = await http.get(Uri.parse(_privacyPolicyUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        print('✓ Privacy policy downloaded');
        // Cache it
        await _saveToCacheFile(response.body);
        return response.body;
      }
    } catch (e) {
      print('✗ Failed to download privacy policy: $e');
    }

    // Try cache
    final cached = await _loadFromCacheFile();
    if (cached.isNotEmpty) {
      print('✓ Using cached privacy policy');
      return cached;
    }

    // Fallback to markdown from assets
    print('Loading from assets fallback...');
    return await _loadMarkdownAsHtml();
  }

  // Save to cache
  static Future<void> _saveToCacheFile(String content) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final file = File('${cacheDir.path}/$_cacheFileName');
      await file.writeAsString(content);
      print('✓ Saved to cache');
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }

  // Load from cache
  static Future<String> _loadFromCacheFile() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final file = File('${cacheDir.path}/$_cacheFileName');

      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      print('Error loading from cache: $e');
    }
    return '';
  }

  // Load markdown and convert to simple HTML
  static Future<String> _loadMarkdownAsHtml() async {
    try {
      final markdown = await rootBundle.loadString('assets/PRIVACY_POLICY.md');
      // Convert markdown to simple HTML for display
      return _markdownToHtml(markdown);
    } catch (e) {
      print('Error loading from assets: $e');
      return '<html><body><p>Privacy Policy not available</p></body></html>';
    }
  }

  // Simple markdown to HTML converter
  static String _markdownToHtml(String markdown) {
    String html = markdown;
    
    // Headers
    html = html.replaceAllMapped(RegExp(r'^### (.+)$', multiLine: true), 
        (match) => '<h3>${match.group(1)}</h3>');
    html = html.replaceAllMapped(RegExp(r'^## (.+)$', multiLine: true), 
        (match) => '<h2>${match.group(1)}</h2>');
    html = html.replaceAllMapped(RegExp(r'^# (.+)$', multiLine: true), 
        (match) => '<h1>${match.group(1)}</h1>');
    
    // Bold
    html = html.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), 
        (match) => '<strong>${match.group(1)}</strong>');
    
    // Lists
    html = html.replaceAllMapped(RegExp(r'^- (.+)$', multiLine: true), 
        (match) => '<li>${match.group(1)}</li>');
    html = html.replaceAllMapped(RegExp(r'(<li>.+?<\/li>\n?)+', multiLine: true), 
        (match) => '<ul>${match.group(0)}</ul>');
    
    // Links
    html = html.replaceAllMapped(RegExp(r'\[(.+?)\]\((.+?)\)'), 
        (match) => '<a href="${match.group(2)}">${match.group(1)}</a>');
    
    // Paragraphs
    html = html.replaceAll(RegExp(r'\n\n+'), '</p><p>');
    html = '<p>$html</p>';
    
    // Basic HTML structure
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            line-height: 1.6;
            padding: 20px;
            color: #333;
            max-width: 900px;
            margin: 0 auto;
        }
        h1, h2, h3 { margin-top: 20px; margin-bottom: 10px; }
        h1 { font-size: 2em; }
        h2 { font-size: 1.5em; }
        h3 { font-size: 1.2em; }
        p { margin-bottom: 15px; }
        ul, li { margin-left: 20px; margin-bottom: 10px; }
        strong { font-weight: 600; }
        a { color: #1f4788; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
$html
</body>
</html>
''';
  }

  static Future<void> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final file = File('${cacheDir.path}/$_cacheFileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
