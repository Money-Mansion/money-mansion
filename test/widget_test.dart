import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_mansion/main.dart';
import 'package:money_mansion/models/game_state.dart';
import 'package:money_mansion/models/room.dart';
import 'package:money_mansion/services/app_localizations_provider.dart';
import 'package:money_mansion/services/tutorial_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    AudioplayersPlatformInterface.instance = _FakeAudioplayersPlatform();
    GlobalAudioplayersPlatformInterface.instance =
        _FakeGlobalAudioplayersPlatform();

    SharedPreferences.setMockInitialValues({
      'tutorial_completed': true,
      'isFirstLaunch': false,
      'privacy_policy_consent': true,
      'privacy_policy_version': 1,
    });
  });

  testWidgets('Money Mansion app loads the game shell', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await _pumpUntilFound(tester, find.byKey(const Key('nav_button_0')));

    expect(find.byKey(const Key('nav_button_0')), findsOneWidget);
    expect(find.byKey(const Key('nav_button_1')), findsOneWidget);
    expect(find.byKey(const Key('nav_button_2')), findsOneWidget);
    expect(find.byKey(const Key('nav_button_3')), findsOneWidget);
    await _clearPendingUiTimers(tester);
  });

}

Widget _buildTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => GameState(
          coins: 100,
          money: 0,
          date: 7.7,
          musicEnabled: false,
          musicVolume: 0,
          rooms: [Room()],
        ),
      ),
      ChangeNotifierProvider(create: (_) => AppLocalizationsProvider()),
      ChangeNotifierProvider(create: (_) => TutorialProvider()),
    ],
    child: const MoneyMansionApp(
      isFirstLaunch: false,
      hasPrivacyConsent: true,
    ),
  );
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 20,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 250));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Expected to find $finder after pumping.');
}

Future<void> _clearPendingUiTimers(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

class _FakeGlobalAudioplayersPlatform
    implements GlobalAudioplayersPlatformInterface {
  @override
  Future<void> emitGlobalError(String code, String message) async {}

  @override
  Future<void> emitGlobalLog(String message) async {}

  @override
  Stream<GlobalAudioEvent> getGlobalEventStream() => const Stream.empty();

  @override
  Future<void> init() async {}

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) async {}
}

class _FakeAudioplayersPlatform extends AudioplayersPlatformInterface {
  @override
  Future<void> create(String playerId) async {}

  @override
  Future<void> dispose(String playerId) async {}

  @override
  Future<void> emitError(String playerId, String code, String message) async {}

  @override
  Future<void> emitLog(String playerId, String message) async {}

  @override
  Future<int?> getCurrentPosition(String playerId) async => null;

  @override
  Future<int?> getDuration(String playerId) async => null;

  @override
  Stream<AudioEvent> getEventStream(String playerId) => const Stream.empty();

  @override
  Future<void> pause(String playerId) async {}

  @override
  Future<void> release(String playerId) async {}

  @override
  Future<void> resume(String playerId) async {}

  @override
  Future<void> seek(String playerId, Duration position) async {}

  @override
  Future<void> setAudioContext(
    String playerId,
    AudioContext audioContext,
  ) async {}

  @override
  Future<void> setBalance(String playerId, double balance) async {}

  @override
  Future<void> setPlayerMode(String playerId, PlayerMode playerMode) async {}

  @override
  Future<void> setPlaybackRate(String playerId, double playbackRate) async {}

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) async {}

  @override
  Future<void> setSourceBytes(
    String playerId,
    Uint8List bytes, {
    String? mimeType,
  }) async {}

  @override
  Future<void> setSourceUrl(
    String playerId,
    String url, {
    bool? isLocal,
    String? mimeType,
  }) async {}

  @override
  Future<void> setVolume(String playerId, double volume) async {}

  @override
  Future<void> stop(String playerId) async {}
}
