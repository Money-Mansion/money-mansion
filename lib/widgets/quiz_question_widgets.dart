// ============================================================
// QUIZ QUESTION WIDGETS
// File: lib/widgets/quiz_question_widgets.dart
// ============================================================

import 'package:flutter/material.dart';
import 'dart:math';
import '../models/quiz_question_types.dart' as qt;
typedef QuizQuestion = qt.QuizQuestion;
typedef QuestionType = qt.QuestionType;

typedef OnAnswered = void Function(bool isCorrect);

String _tr(String key, String language) {
  const _strings = <String, Map<String, String>>{
    'trueLabel':    {'sk': 'Pravda',   'en': 'True'},
    'falseLabel':   {'sk': 'Nepravda', 'en': 'False'},
    'orderHint':    {'sk': 'Potiahni položky do správneho poradia:', 'en': 'Drag to put in the correct order:'},
    'checkOrder':   {'sk': 'Skontrolovať poradie', 'en': 'Check Order'},
    'matchHint':    {'sk': 'Klepni na ľavú položku a potom na jej zhodu vpravo:', 'en': 'Tap a left item, then tap its match on the right:'},
    'checkMatches': {'sk': 'Skontrolovať zhody', 'en': 'Check Matches'},
    'matchAllFirst':{'sk': 'Najprv spáruj všetky dvojice', 'en': 'Match all pairs first'},
    'dragHint':     {'sk': 'Presuň každý štítok do správneho poľa:', 'en': 'Drag each label to the correct box:'},
    'checkAnswers': {'sk': 'Skontrolovať odpovede', 'en': 'Check Answers'},
    'placeAllFirst':{'sk': 'Najprv umiestni všetky štítky', 'en': 'Place all labels first'},
  };
  final isSk = language == 'sk';
  return _strings[key]?[isSk ? 'sk' : 'en'] ?? key;
}

// ── Factory ──────────────────────────────────────────────────

class QuestionWidgetFactory {
  static Widget build({
    required QuizQuestion question,
    required bool showFeedback,
    required OnAnswered onAnswered,
    required String language,
  }) {
    switch (question.questionType) {
      case QuestionType.multipleChoice:
        return MultipleChoiceWidget(
          question: question,
          showFeedback: showFeedback,
          onAnswered: onAnswered,
        );
      case QuestionType.trueFalse:
        return TrueFalseWidget(
          question: question,
          showFeedback: showFeedback,
          onAnswered: onAnswered,
          language: language,
        );
      case QuestionType.ordering:
        return OrderingWidget(
          question: question,
          showFeedback: showFeedback,
          onAnswered: onAnswered,
          language: language,
        );
      case QuestionType.matching:
        return MatchingWidget(
          question: question,
          showFeedback: showFeedback,
          onAnswered: onAnswered,
          language: language,
        );
      case QuestionType.dragDrop:
        return DragDropWidget(
          question: question,
          showFeedback: showFeedback,
          onAnswered: onAnswered,
          language: language,
        );
    }
  }
}

// ────────────────────────────────────────────────────────────
// 1. MULTIPLE CHOICE  (FIXED)
// ────────────────────────────────────────────────────────────

class MultipleChoiceWidget extends StatefulWidget {
  final QuizQuestion question;
  final bool showFeedback;
  final OnAnswered onAnswered;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    required this.showFeedback,
    required this.onAnswered,
  });

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    // Only reveal correct/wrong colours AFTER the parent sets showFeedback=true.
    // Before that, the selected option just shows a neutral "chosen" highlight.
    final revealed = widget.showFeedback && _selected != null;

    return Column(
      children: List.generate(widget.question.options.length, (index) {
        final isSelected = _selected == index;
        final isCorrect  = index == widget.question.correctAnswer;
        final isWrong    = isSelected && !isCorrect;

        Color bg     = Colors.white;
        Color border = Colors.grey[300]!;

        if (revealed) {
          // Show full green/red feedback
          if (isCorrect) {
            bg     = const Color(0xFF4CAF50).withOpacity(0.1);
            border = const Color(0xFF4CAF50);
          } else if (isWrong) {
            bg     = const Color(0xFFF44336).withOpacity(0.1);
            border = const Color(0xFFF44336);
          }
        } else if (isSelected) {
          // Just highlight the chosen option neutrally while waiting for feedback
          bg     = const Color(0xFF7C3AED).withOpacity(0.08);
          border = const Color(0xFF7C3AED);
        }

        return GestureDetector(
          onTap: _selected != null
              ? null
              : () {
                  setState(() => _selected = index);
                  widget.onAnswered(index == widget.question.correctAnswer);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question.options[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                if (revealed && isCorrect)
                  const Icon(Icons.check_circle,
                      color: Color(0xFF4CAF50), size: 24)
                else if (revealed && isWrong)
                  const Icon(Icons.cancel,
                      color: Color(0xFFF44336), size: 24)
                else if (!revealed && isSelected)
                  const Icon(Icons.radio_button_checked,
                      color: Color(0xFF7C3AED), size: 24),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ────────────────────────────────────────────────────────────
// 2. TRUE / FALSE  (same fix applied for consistency)
// ────────────────────────────────────────────────────────────

class TrueFalseWidget extends StatefulWidget {
  final QuizQuestion question;
  final bool showFeedback;
  final OnAnswered onAnswered;
  final String language;

  const TrueFalseWidget({
    super.key,
    required this.question,
    required this.showFeedback,
    required this.onAnswered,
    required this.language,
  });

  @override
  State<TrueFalseWidget> createState() => _TrueFalseWidgetState();
}

class _TrueFalseWidgetState extends State<TrueFalseWidget> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final trueLabel  = _tr('trueLabel',  widget.language);
    final falseLabel = _tr('falseLabel', widget.language);
    final revealed   = widget.showFeedback && _selected != null;

    return Row(
      children: [
        Expanded(
          child: _buildButton(0, Icons.check, const Color(0xFF4CAF50), trueLabel,  revealed),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildButton(1, Icons.close, const Color(0xFFF44336), falseLabel, revealed),
        ),
      ],
    );
  }

  Widget _buildButton(
      int index, IconData icon, Color activeColor, String label, bool revealed) {
    final isSelected = _selected == index;
    final isCorrect  = widget.question.correctAnswer == index;
    final answered   = _selected != null;

    Color bg        = Colors.grey[100]!;
    Color border    = Colors.grey[300]!;
    Color iconColor = Colors.grey[600]!;

    if (revealed) {
      if (isCorrect) {
        bg = const Color(0xFF4CAF50).withOpacity(0.1);
        border = const Color(0xFF4CAF50);
        iconColor = const Color(0xFF4CAF50);
      } else if (isSelected && !isCorrect) {
        bg = const Color(0xFFF44336).withOpacity(0.1);
        border = const Color(0xFFF44336);
        iconColor = const Color(0xFFF44336);
      }
    } else if (isSelected) {
      // Neutral selected state before feedback
      bg = const Color(0xFF7C3AED).withOpacity(0.08);
      border = const Color(0xFF7C3AED);
      iconColor = const Color(0xFF7C3AED);
    }

    return GestureDetector(
      onTap: answered
          ? null
          : () {
              setState(() => _selected = index);
              widget.onAnswered(index == widget.question.correctAnswer);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// 3. ORDERING
// ────────────────────────────────────────────────────────────

class OrderingWidget extends StatefulWidget {
  final QuizQuestion question;
  final bool showFeedback;
  final OnAnswered onAnswered;
  final String language;

  const OrderingWidget({
    super.key,
    required this.question,
    required this.showFeedback,
    required this.onAnswered,
    required this.language,
  });

  @override
  State<OrderingWidget> createState() => _OrderingWidgetState();
}

class _OrderingWidgetState extends State<OrderingWidget> {
  late List<String> _items;
  bool _submitted = false;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.question.orderItems);
    do {
      _items.shuffle(Random());
    } while (_items.length > 1 && _listEquals(_items, widget.question.orderItems));
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _submit() {
    final correct = _listEquals(_items, widget.question.orderItems);
    setState(() {
      _submitted = true;
      _isCorrect = correct;
    });
    widget.onAnswered(correct);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _tr('orderHint', widget.language),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: !_submitted,
          onReorder: _submitted
              ? (_, __) {}
              : (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _items.removeAt(oldIndex);
                    _items.insert(newIndex, item);
                  });
                },
          children: _items.asMap().entries.map((entry) {
            final i    = entry.key;
            final text = entry.value;
            final isCorrectPos = _submitted && widget.question.orderItems[i] == text;
            final isWrongPos   = _submitted && widget.question.orderItems[i] != text;

            return Container(
              key: ValueKey(text),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _submitted
                    ? (isCorrectPos
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : const Color(0xFFF44336).withOpacity(0.1))
                    : Colors.white,
                border: Border.all(
                  color: _submitted
                      ? (isCorrectPos ? const Color(0xFF4CAF50) : const Color(0xFFF44336))
                      : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
                  if (!_submitted)
                    Icon(Icons.drag_handle, color: Colors.grey[400])
                  else if (isCorrectPos)
                    const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20)
                  else if (isWrongPos)
                    const Icon(Icons.cancel, color: Color(0xFFF44336), size: 20),
                ],
              ),
            );
          }).toList(),
        ),
        if (!_submitted) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_tr('checkOrder', widget.language), style: const TextStyle(fontSize: 16)),
          ),
        ],
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────
// 4. MATCHING
// ────────────────────────────────────────────────────────────

class MatchingWidget extends StatefulWidget {
  final QuizQuestion question;
  final bool showFeedback;
  final OnAnswered onAnswered;
  final String language;

  const MatchingWidget({
    super.key,
    required this.question,
    required this.showFeedback,
    required this.onAnswered,
    required this.language,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> {
  late List<String> _shuffledRight;
  late List<int?> _userMatches;
  int? _selectedLeft;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _shuffledRight = List.from(widget.question.matchRight)..shuffle(Random());
    _userMatches   = List.filled(widget.question.matchLeft.length, null);
  }

  bool get _allMatched => _userMatches.every((m) => m != null);

  void _submit() {
    bool allCorrect = true;
    for (int i = 0; i < widget.question.matchLeft.length; i++) {
      final ri = _userMatches[i];
      if (ri == null || _shuffledRight[ri] != widget.question.matchRight[i]) {
        allCorrect = false;
        break;
      }
    }
    setState(() => _submitted = true);
    widget.onAnswered(allCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.question.matchLeft;

    final rightUsed = <int, int>{};
    for (int li = 0; li < _userMatches.length; li++) {
      if (_userMatches[li] != null) rightUsed[_userMatches[li]!] = li;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _tr('matchHint', widget.language),
          style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        ...List.generate(left.length, (i) {
          final ri        = _userMatches[i];
          final isMatched = ri != null;
          final isSelected = _selectedLeft == i;

          bool pairCorrect = false;
          if (_submitted && isMatched) {
            pairCorrect = _shuffledRight[ri] == widget.question.matchRight[i];
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _submitted
                          ? null
                          : () => setState(() => _selectedLeft = isSelected ? null : i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: _submitted
                              ? (pairCorrect
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : const Color(0xFFF44336).withOpacity(0.1))
                              : isSelected
                                  ? const Color(0xFF2196F3).withOpacity(0.12)
                                  : isMatched
                                      ? const Color(0xFF9C27B0).withOpacity(0.08)
                                      : Colors.grey[50],
                          border: Border.all(
                            color: _submitted
                                ? (pairCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336))
                                : isSelected
                                    ? const Color(0xFF2196F3)
                                    : isMatched
                                        ? const Color(0xFF9C27B0)
                                        : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(left[i], style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: isMatched
                          ? const Icon(Icons.link, color: Color(0xFF9C27B0), size: 16)
                          : Icon(Icons.more_horiz, color: Colors.grey[300], size: 16),
                    ),
                  ),
                  Expanded(
                    child: isMatched
                        ? _buildRightCell(ri, rightUsed, pairCorrect)
                        : GestureDetector(
                            onTap: null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedLeft != null
                                    ? const Color(0xFF2196F3).withOpacity(0.04)
                                    : Colors.grey[50],
                                border: Border.all(
                                  color: _selectedLeft != null
                                      ? const Color(0xFF2196F3).withOpacity(0.3)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('—', style: TextStyle(color: Colors.grey[400])),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_shuffledRight.length, (ri) {
            final alreadyUsed = rightUsed.containsKey(ri);
            if (alreadyUsed) return const SizedBox.shrink();
            return GestureDetector(
              onTap: _submitted || _selectedLeft == null
                  ? null
                  : () {
                      setState(() {
                        for (int li = 0; li < _userMatches.length; li++) {
                          if (_userMatches[li] == ri) _userMatches[li] = null;
                        }
                        _userMatches[_selectedLeft!] = ri;
                        _selectedLeft = null;
                      });
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedLeft != null
                      ? const Color(0xFF2196F3).withOpacity(0.08)
                      : Colors.grey[50],
                  border: Border.all(
                    color: _selectedLeft != null
                        ? const Color(0xFF2196F3).withOpacity(0.5)
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_shuffledRight[ri], style: const TextStyle(fontSize: 14)),
              ),
            );
          }),
        ),
        if (!_submitted) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _allMatched ? _submit : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _allMatched ? _tr('checkMatches', widget.language) : _tr('matchAllFirst', widget.language),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRightCell(int ri, Map<int, int> rightUsed, bool pairCorrect) {
    final matchedToLeft = rightUsed[ri];
    return GestureDetector(
      onTap: _submitted
          ? null
          : () {
              setState(() {
                if (matchedToLeft != null) _userMatches[matchedToLeft] = null;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _submitted
              ? (pairCorrect
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : const Color(0xFFF44336).withOpacity(0.1))
              : const Color(0xFF9C27B0).withOpacity(0.08),
          border: Border.all(
            color: _submitted
                ? (pairCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336))
                : const Color(0xFF9C27B0),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(child: Text(_shuffledRight[ri], style: const TextStyle(fontSize: 14))),
            if (_submitted)
              Icon(
                pairCorrect ? Icons.check_circle : Icons.cancel,
                color: pairCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// 5. DRAG & DROP
// ────────────────────────────────────────────────────────────

class DragDropWidget extends StatefulWidget {
  final QuizQuestion question;
  final bool showFeedback;
  final OnAnswered onAnswered;
  final String language;

  const DragDropWidget({
    super.key,
    required this.question,
    required this.showFeedback,
    required this.onAnswered,
    required this.language,
  });

  @override
  State<DragDropWidget> createState() => _DragDropWidgetState();
}

class _DragDropWidgetState extends State<DragDropWidget> {
  late Map<int, String?> _placed;
  late List<String> _bank;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _bank   = List.from(widget.question.dragLabels)..shuffle(Random());
    _placed = {for (int i = 0; i < widget.question.dragTargets.length; i++) i: null};
  }

  bool get _allPlaced => _placed.values.every((v) => v != null);

  void _submit() {
    bool allCorrect = true;
    for (int i = 0; i < widget.question.dragTargets.length; i++) {
      if (_placed[i] != widget.question.dragTargets[i].correctItem) {
        allCorrect = false;
        break;
      }
    }
    setState(() => _submitted = true);
    widget.onAnswered(allCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _tr('dragHint', widget.language),
          style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 16),
        if (_bank.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bank.map((label) {
              return _submitted
                  ? _chipWidget(label)
                  : Draggable<String>(
                      data: label,
                      feedback: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(20),
                        child: _chipWidget(label, dragging: true),
                      ),
                      childWhenDragging: _chipWidget(label, faded: true),
                      child: _chipWidget(label),
                    );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
        ...List.generate(widget.question.dragTargets.length, (i) {
          final target    = widget.question.dragTargets[i];
          final placed    = _placed[i];
          final isCorrect = _submitted && placed == target.correctItem;
          final isWrong   = _submitted && placed != null && placed != target.correctItem;

          return DragTarget<String>(
            onWillAcceptWithDetails: (_) => !_submitted,
            onAcceptWithDetails: (details) {
              setState(() {
                _bank.remove(details.data);
                if (placed != null) _bank.add(placed);
                for (int j = 0; j < widget.question.dragTargets.length; j++) {
                  if (j != i && _placed[j] == details.data) _placed[j] = null;
                }
                _placed[i] = details.data;
              });
            },
            builder: (context, candidateData, _) {
              final isHovered = candidateData.isNotEmpty;
              return GestureDetector(
                onTap: placed != null && !_submitted
                    ? () => setState(() {
                          _bank.add(placed);
                          _placed[i] = null;
                        })
                    : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _submitted
                        ? (isCorrect
                            ? const Color(0xFF4CAF50).withOpacity(0.1)
                            : isWrong
                                ? const Color(0xFFF44336).withOpacity(0.1)
                                : Colors.grey[50])
                        : isHovered
                            ? const Color(0xFF2196F3).withOpacity(0.08)
                            : placed != null
                                ? const Color(0xFF9C27B0).withOpacity(0.08)
                                : Colors.grey[50],
                    border: Border.all(
                      color: _submitted
                          ? (isCorrect
                              ? const Color(0xFF4CAF50)
                              : isWrong
                                  ? const Color(0xFFF44336)
                                  : Colors.grey[300]!)
                          : isHovered
                              ? const Color(0xFF2196F3)
                              : placed != null
                                  ? const Color(0xFF9C27B0)
                                  : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          target.label,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      placed != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _submitted
                                    ? (isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336))
                                    : const Color(0xFF9C27B0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                placed,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isHovered ? const Color(0xFF2196F3) : Colors.grey[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '?',
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                      if (_submitted) ...[
                        const SizedBox(width: 8),
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        }),
        if (!_submitted) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _allPlaced ? _submit : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _allPlaced ? _tr('checkAnswers', widget.language) : _tr('placeAllFirst', widget.language),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _chipWidget(String label, {bool dragging = false, bool faded = false}) {
    return Opacity(
      opacity: faded ? 0.35 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: dragging
              ? const Color(0xFF9C27B0).withOpacity(0.9)
              : const Color(0xFF9C27B0).withOpacity(0.1),
          border: Border.all(color: const Color(0xFF9C27B0), width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: dragging ? Colors.white : const Color(0xFF9C27B0),
          ),
        ),
      ),
    );
  }
}