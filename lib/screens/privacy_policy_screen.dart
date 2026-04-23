import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../services/privacy_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late Future<String> _privacyPolicyFuture;

  @override
  void initState() {
    super.initState();
    _privacyPolicyFuture = PrivacyService.getPrivacyPolicyHtml();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        elevation: 0,
      ),
      body: FutureBuilder<String>(
        future: _privacyPolicyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading Privacy Policy',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }

          final html = snapshot.data ?? '';
          if (html.isEmpty) {
            return const Center(child: Text('No Privacy Policy available'));
          }

          final blocks = _buildBlocksFromHtml(context, html);

          return LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth * 0.8;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: blocks,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildBlocksFromHtml(BuildContext context, String html) {
    final document = html_parser.parse(html);
    final root = document.querySelector('.doc-content') ?? document.body;
    if (root == null) {
      return const [Text('Privacy Policy not available')];
    }

    final widgets = <Widget>[];
    for (final node in root.nodes) {
      final block = _buildBlock(context, node);
      if (block != null) {
        widgets.add(block);
      }
    }

    if (widgets.isEmpty) {
      widgets.add(const Text('Privacy Policy not available'));
    }

    return widgets;
  }

  Widget? _buildBlock(BuildContext context, dom.Node node) {
    if (node is dom.Text) {
      final text = node.text.trim();
      if (text.isEmpty) return null;
      return _paragraph(context, [TextSpan(text: text)]);
    }

    if (node is! dom.Element) return null;

    switch (node.localName) {
      case 'h1':
        return _heading(context, node.nodes, 24);
      case 'h2':
        return _heading(context, node.nodes, 22);
      case 'h3':
        return _heading(context, node.nodes, 20);
      case 'h4':
        return _heading(context, node.nodes, 18);
      case 'h5':
        return _heading(context, node.nodes, 16);
      case 'h6':
        return _heading(context, node.nodes, 15);
      case 'p':
        return _paragraph(context, _inlineSpans(node.nodes));
      case 'ul':
        return _buildList(context, node, ordered: false);
      case 'ol':
        return _buildList(context, node, ordered: true);
      case 'hr':
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, thickness: 1),
        );
      case 'table':
        return _buildTable(context, node);
      case 'div':
      case 'section':
      case 'article':
      case 'main':
        final children = <Widget>[];
        for (final child in node.nodes) {
          final built = _buildBlock(context, child);
          if (built != null) children.add(built);
        }
        if (children.isEmpty) return null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      default:
        final spans = _inlineSpans(node.nodes);
        if (spans.isEmpty) return null;
        return _paragraph(context, spans);
    }
  }

  Widget _heading(BuildContext context, List<dom.Node> nodes, double size) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: SelectableText.rich(
        TextSpan(
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            height: 1.3,
          ),
          children: _inlineSpans(nodes),
        ),
      ),
    );
  }

  Widget _paragraph(BuildContext context, List<InlineSpan> spans) {
    if (spans.isEmpty) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SelectableText.rich(
        TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.45,
          ),
          children: spans,
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, dom.Element listElement,
      {required bool ordered}) {
    final items =
        listElement.children.where((e) => e.localName == 'li').toList();
    if (items.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final marker = ordered ? '${i + 1}.' : '•';
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  marker,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              Expanded(
                child: SelectableText.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.45,
                    ),
                    children: _inlineSpans(items[i].nodes),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(children: children),
    );
  }

  Widget _buildTable(BuildContext context, dom.Element table) {
    final rows = table.children.where((e) => e.localName == 'tr').toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    final rowWidgets = <Widget>[];
    for (final row in rows) {
      final cells = row.children
          .where((e) => e.localName == 'td' || e.localName == 'th')
          .toList();
      if (cells.isEmpty) continue;

      rowWidgets.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final cell in cells)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                  ),
                  child: SelectableText.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: cell.localName == 'th'
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      children: _inlineSpans(cell.nodes),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(children: rowWidgets),
    );
  }

  List<InlineSpan> _inlineSpans(List<dom.Node> nodes, {TextStyle? style}) {
    final spans = <InlineSpan>[];

    for (final node in nodes) {
      if (node is dom.Text) {
        final text = node.text;
        if (text.isNotEmpty) {
          spans.add(TextSpan(text: text, style: style));
        }
        continue;
      }

      if (node is! dom.Element) continue;

      if (node.localName == 'br') {
        spans.add(const TextSpan(text: '\n'));
        continue;
      }

      var childStyle = style;
      if (node.localName == 'strong' || node.localName == 'b') {
        childStyle = (childStyle ?? const TextStyle())
            .copyWith(fontWeight: FontWeight.w700);
      }
      if (node.localName == 'em' || node.localName == 'i') {
        childStyle = (childStyle ?? const TextStyle())
            .copyWith(fontStyle: FontStyle.italic);
      }

      spans.addAll(_inlineSpans(node.nodes, style: childStyle));
    }

    return spans;
  }
}
