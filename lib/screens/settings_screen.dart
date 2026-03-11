import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/app_localizations_provider.dart';

class SettingsScreen extends StatelessWidget {
  final GameState gameState;

  const SettingsScreen({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLocalizationsProvider>(
      builder: (context, localizationsProvider, _) {
        final l10n = localizationsProvider;
        final supportedLanguages = l10n.getSupportedLanguages();

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.translate('settings')),
            backgroundColor: Colors.orange[500],
            elevation: 0,
            automaticallyImplyLeading: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Selection Card
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('selectLanguage'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: supportedLanguages.map((languageCode) {
                              final isSelected =
                                  languageCode == l10n.currentLanguage;
                              final languageName =
                                  l10n.getLanguageName(languageCode);

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.orange
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  title: Text(languageName),
                                  leading: Radio<String>(
                                    value: languageCode,
                                    groupValue: l10n.currentLanguage,
                                    onChanged: (value) {
                                      if (value != null) {
                                        l10n.setLanguage(value);
                                      }
                                    },
                                    activeColor: Colors.orange,
                                  ),
                                  onTap: () {
                                    l10n.setLanguage(languageCode);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Game Preferences Section
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('gamePreferences'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.translate('moreSettingsComingSoon'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Game Info Section
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('gameInfo'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          // Coins
                          AnimatedBuilder(
                            animation: gameState,
                            builder: (context, _) => Column(
                              children: [
                                _InfoRow(
                                  label: '${l10n.translate('coins')}:',
                                  value: '${gameState.coins}',
                                  valueColor: Colors.orange,
                                ),
                                const SizedBox(height: 12),
                                // Money
                                _InfoRow(
                                  label: '${l10n.translate('money')}:',
                                  value: '\$${gameState.money.toStringAsFixed(2)}',
                                  valueColor: Colors.green,
                                ),
                                const SizedBox(height: 12),
                                // Chrumka
                                _InfoRow(
                                  label: 'Chrumky:',
                                  value: '${gameState.chrumka}',
                                  valueColor: const Color.fromARGB(255, 200, 80, 160),
                                  icon: '🐾',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final String? icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Row(
          children: [
            if (icon != null) ...[
              Text(icon!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}