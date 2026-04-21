import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

class PrivacyService {
  static const String _privacyPolicyUrl =
      'https://docs.google.com/document/d/1GGN1zc9PyD62BLHKO86DUAkBv_THPzauoy9kx1GcUKU/export?format=html';

  static const String _cacheFileName = 'privacy_policy.md';

  // Stiahni Privacy Policy z URL alebo vráť cached verziu
  static Future<String> getPrivacyPolicy() async {
    try {
      // Skús stiahnutie z internetu (HTML format)
      final response = await http.get(Uri.parse(_privacyPolicyUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Konvertuj HTML na Markdown
        final markdown = _htmlToMarkdown(response.body);
        // Ulož do cache
        await _saveToCacheFile(markdown);
        return markdown;
      }
    } catch (e) {
      print('Error downloading privacy policy: $e');
    }

    // Ak sťahovanie zlylo, vráť cached verziu
    final cached = await _loadFromCacheFile();
    if (cached.isNotEmpty) {
      return cached;
    }

    // Ak cache neexistuje, vráť fallback z assets
    return await _loadFromAssets();
  }

  // HTML to Markdown converter - preserves structure and formatting
  static String _htmlToMarkdown(String html) {
    try {
      final document = html_parser.parse(html);
      final body = document.body;
      
      if (body == null) return '';
      
      final buffer = StringBuffer();
      _parseNode(body, buffer);
      
      // Clean up excess whitespace while preserving paragraph breaks
      String markdown = buffer.toString();
      markdown = markdown.replaceAll(RegExp(r'\n\n\n+'), '\n\n'); // Multiple blank lines → 2
      markdown = markdown.trim();
      
      return markdown;
    } catch (e) {
      print('Error converting HTML to Markdown: $e');
      return '';
    }
  }

  // Recursively parse HTML nodes and convert to Markdown
  static void _parseNode(Node node, StringBuffer buffer) {
    if (node is Text) {
      String text = node.text.trim();
      if (text.isNotEmpty) {
        buffer.write(text);
      }
    } else if (node is Element) {
      switch (node.localName) {
        // Headings
        case 'h1':
          buffer.write('# ');
          for (var child in node.nodes) _parseNode(child, buffer);
          buffer.write('\n\n');
          break;
        case 'h2':
          buffer.write('## ');
          for (var child in node.nodes) _parseNode(child, buffer);
          buffer.write('\n\n');
          break;
        case 'h3':
          buffer.write('### ');
          for (var child in node.nodes) _parseNode(child, buffer);
          buffer.write('\n\n');
          break;
        case 'h4':
          buffer.write('#### ');
          for (var child in node.nodes) _parseNode(child, buffer);
          buffer.write('\n\n');
          break;
        case 'h5':
          buffer.write('##### ');
          for (var child in node.nodes) _parseNode(child, buffer);
          buffer.write('\n\n');
          break;
        case 'h6':
          buffer.write('###### ');
          for (var child in node.nodes) _parseNode(child, buffer);
          buffer.write('\n\n');
          break;
        // Paragraphs
        case 'p':
          for (var child in node.nodes) _parseNode(child, buffer);
          buffer.write('\n\n');
          break;
        // Line breaks
        case 'br':
          buffer.write('\n');
          break;
        // Bold
        case 'strong':
        case 'b':
          buffer.write('**');
          for (var child in node.nodes) _parseNode(child, buffer);
          buffer.write('**');
          break;
        // Italic
        case 'em':
        case 'i':
          buffer.write('*');
          for (var child in node.nodes) _parseNode(child, buffer);
          buffer.write('*');
          break;
        // Links
        case 'a':
          buffer.write('[');
          for (var child in node.nodes) _parseNode(child, buffer);
          buffer.write('](${node.attributes['href'] ?? "#"})');
          break;
        // Lists
        case 'ul':
          buffer.write('\n');
          for (var child in node.nodes) {
            if (child is Element && child.localName == 'li') {
              buffer.write('- ');
              for (var liChild in child.nodes) _parseNode(liChild, buffer);
              buffer.write('\n');
            } else if (child is! Text || child.text.trim().isNotEmpty) {
              _parseNode(child, buffer);
            }
          }
          buffer.write('\n');
          break;
        case 'ol':
          buffer.write('\n');
          int index = 1;
          for (var child in node.nodes) {
            if (child is Element && child.localName == 'li') {
              buffer.write('$index. ');
              for (var liChild in child.nodes) _parseNode(liChild, buffer);
              buffer.write('\n');
              index++;
            } else if (child is! Text || child.text.trim().isNotEmpty) {
              _parseNode(child, buffer);
            }
          }
          buffer.write('\n');
          break;
        case 'li':
          for (var child in node.nodes) _parseNode(child, buffer);
          break;
        // Blockquotes
        case 'blockquote':
          buffer.write('> ');
          for (var child in node.nodes) {
            String text = _nodeToString(child).trim();
            buffer.write(text.replaceAll('\n', '\n> '));
          }
          buffer.write('\n\n');
          break;
        // Divs, sections - just process children
        case 'div':
        case 'section':
        case 'article':
        case 'main':
          for (var child in node.nodes) _parseNode(child, buffer);
          break;
        // Skip style, script, etc.
        case 'style':
        case 'script':
        case 'head':
          break;
        // Default - process children
        default:
          for (var child in node.nodes) _parseNode(child, buffer);
      }
    } else {
      // For other node types, process children
      for (var child in (node as Element?)?.nodes ?? []) {
        _parseNode(child, buffer);
      }
    }
  }

  // Helper to convert a node to plain text
  static String _nodeToString(Node node) {
    if (node is Text) return node.text;
    if (node is Element) {
      return node.nodes.map(_nodeToString).join();
    }
    return '';
  }

  // Ulož do cache
  static Future<void> _saveToCacheFile(String content) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final file = File('${cacheDir.path}/$_cacheFileName');
      await file.writeAsString(content);
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }

  // Načítaj z cache
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

  // Načítaj z assets (fallback)
  static Future<String> _loadFromAssets() async {
    try {
      return await rootBundle.loadString('assets/PRIVACY_POLICY.md');
    } catch (e) {
      print('Error loading from assets: $e');
      return 'Privacy Policy not available';
    }
  }

  // Vymaž cache a vynúť nové stiahnutie
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
