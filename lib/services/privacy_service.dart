import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PrivacyService {
  static const String _privacyPolicyUrl =
      'https://docs.google.com/document/d/1GGN1zc9PyD62BLHKO86DUAkBv_THPzauoy9kx1GcUKU/export?format=txt';

  static const String _cacheFileName = 'privacy_policy.txt';

  // Stiahni Privacy Policy z URL alebo vráť cached verziu
  static Future<String> getPrivacyPolicy() async {
    try {
      // Skús stiahnutie z internetu
      final response = await http.get(Uri.parse(_privacyPolicyUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Ulož do cache
        await _saveToCacheFile(response.body);
        return response.body;
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
