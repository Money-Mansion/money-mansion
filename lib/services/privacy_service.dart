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
        // Clean up Google Docs HTML
        String cleanedHtml = _cleanGoogleDocsHtml(response.body);
        // Cache it
        await _saveToCacheFile(cleanedHtml);
        return cleanedHtml;
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

  // Clean up Google Docs exported HTML
  static String _cleanGoogleDocsHtml(String html) {
    // Remove Google Docs styles that might mess up layout
    html = html.replaceAll(RegExp(r'style="[^"]*max-width[^"]*"', multiLine: true), '');
    html = html.replaceAll(RegExp(r'style="[^"]*margin:[^"]*auto[^"]*"', multiLine: true), '');
    html = html.replaceAll(RegExp(r'<style[^>]*>.*?<\/style>', dotAll: true), '');
    
    // Format current date
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Wrap in proper mobile HTML with last updated date
    return '''
<!DOCTYPE html>
<html style="width: 100%; height: 100%;">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        html {
            width: 100%;
            height: 100%;
            background: #fff;
        }
        body {
            width: 100% !important;
            max-width: 100% !important;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            font-size: 16px;
            line-height: 1.8;
            padding: 16px !important;
            margin: 0 !important;
            color: #212121;
            background: #fff;
            overflow-x: hidden;
        }
        .last-updated {
            font-size: 12px;
            color: #999;
            margin-bottom: 16px;
            padding-bottom: 8px;
            border-bottom: 1px solid #e0e0e0;
        }
        * { max-width: 100% !important; }
        h1, h2, h3, h4, h5, h6 { margin: 16px 0 8px 0; }
        p { 
            margin: 12px 0; 
            word-wrap: break-word; 
            overflow-wrap: break-word;
            white-space: normal;
        }
        a { color: #1f4788; }
    </style>
</head>
<body>
<div class="last-updated">Last Updated: $dateStr</div>
$html
</body>
</html>
''';
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
    
    // Format current date
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Basic HTML structure with better mobile support and last updated date
    return '''
<!DOCTYPE html>
<html style="width: 100%; height: 100%;">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        html {
            width: 100%;
            height: 100%;
            background: #fff;
        }
        body {
            width: 100%;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            font-size: 16px;
            line-height: 1.8;
            padding: 16px;
            color: #212121;
            background: #fff;
            overflow-x: hidden;
        }
        .last-updated {
            font-size: 12px;
            color: #999;
            margin-bottom: 16px;
            padding-bottom: 8px;
            border-bottom: 1px solid #e0e0e0;
        }
        h1 { font-size: 1.8em; font-weight: 600; margin: 24px 0 12px 0; }
        h2 { font-size: 1.4em; font-weight: 600; margin: 20px 0 10px 0; }
        h3 { font-size: 1.1em; font-weight: 600; margin: 16px 0 8px 0; }
        p { 
            margin: 12px 0; 
            word-wrap: break-word; 
            overflow-wrap: break-word;
            white-space: normal;
        }
        ul { margin: 12px 0 12px 20px; }
        li { margin: 6px 0; }
        strong { font-weight: 600; }
        a { 
            color: #1f4788; 
            text-decoration: none; 
            word-break: break-word;
        }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
<div class="last-updated">Last Updated: $dateStr</div>
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
