import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show SystemNavigator, rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

import '../services/onboarding_service.dart';

class PrivacyConsentScreen extends StatefulWidget {
  final VoidCallback onAccepted;

  const PrivacyConsentScreen({super.key, required this.onAccepted});

  @override
  State<PrivacyConsentScreen> createState() => _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends State<PrivacyConsentScreen> {
  late final Future<_PrivacyPolicyContent> _privacyPolicyFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _privacyPolicyFuture = _loadPrivacyPolicyContent();
  }

  Future<_PrivacyPolicyContent> _loadPrivacyPolicyContent() async {
    final text = await rootBundle.loadString('PRIVACY_POLICY.md');
    final fontFamily = _extractFontFamilyFromMarkdown(text) ?? 'serif';
    return _PrivacyPolicyContent(text: text, fontFamily: fontFamily);
  }

  String? _extractFontFamilyFromMarkdown(String markdown) {
    final fontFamilyRegex = RegExp(r'''font-family\s*:\s*["']?([^;"']+)''');
    final fontRegex = RegExp(r'''font\s*:\s*[^;]*["']([^"']+)["']''');

    final familyMatch = fontFamilyRegex.firstMatch(markdown);
    if (familyMatch != null && familyMatch.groupCount >= 1) {
      return familyMatch.group(1)?.trim();
    }

    final fontMatch = fontRegex.firstMatch(markdown);
    if (fontMatch != null && fontMatch.groupCount >= 1) {
      return fontMatch.group(1)?.trim();
    }

    return null;
  }

  Future<void> _acceptPolicy() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await OnboardingService.setPrivacyConsentGiven();
    if (!mounted) {
      return;
    }
    widget.onAccepted();
  }

  void _declinePolicy() {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please close this tab if you do not agree.'),
        ),
      );
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy Consent')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<_PrivacyPolicyContent>(
                future: _privacyPolicyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Failed to load PRIVACY_POLICY.md. Please try again.',
                      ),
                    );
                  }

                  return Markdown(
                    data: snapshot.data?.text ?? '',
                    padding: const EdgeInsets.all(16),
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context),
                    ).copyWith(
                      p: TextStyle(
                        fontFamily: snapshot.data?.fontFamily,
                        height: 1.45,
                      ),
                      h1: TextStyle(fontFamily: snapshot.data?.fontFamily),
                      h2: TextStyle(fontFamily: snapshot.data?.fontFamily),
                      h3: TextStyle(fontFamily: snapshot.data?.fontFamily),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _declinePolicy,
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _acceptPolicy,
                      child: Text(_isSubmitting ? 'Saving...' : 'I Agree'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyPolicyContent {
  final String text;
  final String? fontFamily;

  const _PrivacyPolicyContent({required this.text, required this.fontFamily});
}
