import 'dart:io';

import 'package:flutter/services.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PrivacyService {
  static const String _privacyPolicyUrl =
      'https://docs.google.com/document/d/e/2PACX-1vR8U3M90spZvTWmVuFJGUq7wbu9BdUH_CC5f9op0FzSmyg83d7O4cVI6Ndjodd4fVGbNSnMJaCSLbb3/pub';
  static const String _cacheFileName = 'privacy_policy_cached.html';

  static Future<String> getPrivacyPolicyHtml() async {
    try {
      final response = await http
          .get(Uri.parse(_privacyPolicyUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final sanitized = _sanitizeGoogleDocHtml(response.body);
        if (sanitized.isNotEmpty) {
          await _saveToCacheFile(sanitized);
          return sanitized;
        }
      }
    } catch (_) {
      // Fall back to cache/assets when offline.
    }

    final cached = await _loadFromCacheFile();
    if (cached.isNotEmpty) {
      return _normalizeCachedHtml(cached);
    }

    return _loadFromAssets();
  }

  static String _sanitizeGoogleDocHtml(String sourceHtml) {
    final document = html_parser.parse(sourceHtml);
    final contents = document.getElementById('contents');
    if (contents == null) {
      return '';
    }

    final styleCss =
        contents.querySelectorAll('style').map((e) => e.text).join('\n');
    final boldClasses = _extractClassesByCssRule(
      styleCss,
      (rule) =>
          rule.contains('font-weight:700') || rule.contains('font-weight:bold'),
    );
    final italicClasses = _extractClassesByCssRule(
      styleCss,
      (rule) => rule.contains('font-style:italic'),
    );

    final docContent = contents.querySelector('.doc-content');
    if (docContent == null) {
      return '';
    }

    _normalizeGoogleRedirectLinks(docContent);
    _convertClassBasedFormatting(docContent, boldClasses, italicClasses);
    _stripGoogleDocsAttributes(docContent);

    return _wrapHtml(docContent.outerHtml);
  }

  static String _normalizeCachedHtml(String html) {
    final document = html_parser.parse(html);
    final docContent = document.querySelector('.doc-content') ?? document.body;
    if (docContent == null) {
      return html;
    }

    final styleCss =
        document.querySelectorAll('style').map((e) => e.text).join('\n');
    final boldClasses = _extractClassesByCssRule(
      styleCss,
      (rule) =>
          rule.contains('font-weight:700') || rule.contains('font-weight:bold'),
    );
    final italicClasses = _extractClassesByCssRule(
      styleCss,
      (rule) => rule.contains('font-style:italic'),
    );

    _normalizeGoogleRedirectLinks(docContent);
    _convertClassBasedFormatting(docContent, boldClasses, italicClasses);
    _stripGoogleDocsAttributes(docContent);

    return _wrapHtml(docContent.outerHtml);
  }

  static String _wrapHtml(String bodyContent) {
    return '''
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
  </head>
  <body>
    $bodyContent
  </body>
</html>
''';
  }

  static Set<String> _extractClassesByCssRule(
    String css,
    bool Function(String normalizedRule) predicate,
  ) {
    final result = <String>{};
    final classRuleRegex = RegExp(r'\.([a-zA-Z0-9_-]+)\s*\{([^}]*)\}');

    for (final match in classRuleRegex.allMatches(css)) {
      final className = match.group(1);
      final body = match.group(2);
      if (className == null || body == null) continue;

      final normalized = body.replaceAll(' ', '').toLowerCase();
      if (predicate(normalized)) {
        result.add(className);
      }
    }

    return result;
  }

  static void _convertClassBasedFormatting(
    Element root,
    Set<String> boldClasses,
    Set<String> italicClasses,
  ) {
    final spans = root.querySelectorAll('span').toList(growable: false);
    for (final span in spans) {
      final classes = span.classes;
      final isBold = classes.any(boldClasses.contains);
      final isItalic = classes.any(italicClasses.contains);
      if (!isBold && !isItalic) continue;

      final children = span.nodes.toList(growable: false);
      if (children.isEmpty) continue;

      Node replacement;
      if (isBold && isItalic) {
        final strong = Element.tag('strong');
        final em = Element.tag('em');
        em.nodes.addAll(children);
        strong.nodes.add(em);
        replacement = strong;
      } else if (isBold) {
        final strong = Element.tag('strong');
        strong.nodes.addAll(children);
        replacement = strong;
      } else {
        final em = Element.tag('em');
        em.nodes.addAll(children);
        replacement = em;
      }

      span.replaceWith(replacement);
    }
  }

  static void _stripGoogleDocsAttributes(Element root) {
    for (final element in root.querySelectorAll('*')) {
      element.attributes.remove('class');
      element.attributes.remove('id');
      element.attributes.remove('style');
    }
  }

  static void _normalizeGoogleRedirectLinks(Element root) {
    for (final link in root.querySelectorAll('a[href]')) {
      final href = link.attributes['href'];
      if (href == null) continue;

      final uri = Uri.tryParse(href);
      if (uri == null) continue;

      if (uri.host == 'www.google.com' && uri.path == '/url') {
        final target = uri.queryParameters['q'];
        if (target != null && target.isNotEmpty) {
          link.attributes['href'] = target;
        }
      }
    }
  }

  static Future<void> _saveToCacheFile(String content) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/$_cacheFileName');
      await file.writeAsString(content);
    } catch (_) {}
  }

  static Future<String> _loadFromCacheFile() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/$_cacheFileName');

      if (await file.exists()) {
        return file.readAsString();
      }
    } catch (_) {}

    return '';
  }

  static Future<String> _loadFromAssets() async {
    try {
      return await rootBundle.loadString('assets/privacy_policy_fallback.html');
    } catch (_) {
      return '<p>Privacy Policy not available</p>';
    }
  }

  static Future<void> clearCache() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/$_cacheFileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
