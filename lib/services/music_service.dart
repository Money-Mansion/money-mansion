import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  late AudioPlayer _audioPlayer;
  bool _isPlayingMusic = false;
  bool _isMusicEnabled = true;
  double _currentVolume = 0.5;
  List<String> _musicTracks = [
    'music/track1.mp3',
    'music/track2.mp3',
    'music/track3.mp3',
    'music/track4.mp3'
  ];
  int _currentTrackIndex = 0;

  MusicService._internal() {
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  factory MusicService() {
    return _instance;
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((event) {
      print('✅ Track completed, playing next...');
      _playNextTrack(); // Fire and forget, no await needed
    });
  }

  /// Initialize music service with available tracks
  void initializeTracks(List<String> tracks) {
    if (tracks.isNotEmpty) {
      _musicTracks = tracks;
      _currentTrackIndex = 0;
    }
  }

  /// Start playing music with random track
  Future<void> startMusic() async {
    if (!_isMusicEnabled || _isPlayingMusic) {
      print('⚠️ Cannot start music: enabled=$_isMusicEnabled, playing=$_isPlayingMusic');
      return;
    }
    
    if (_musicTracks.isEmpty) {
      print('⚠️ No music tracks available');
      return;
    }
    
    _currentTrackIndex = Random().nextInt(_musicTracks.length);
    print('🎵 Starting music with track: ${_musicTracks[_currentTrackIndex]}');
    await _playCurrentTrack();
  }

  /// Play current track
  Future<void> _playCurrentTrack() async {
    if (!_isMusicEnabled) {
      print('⚠️ Music is disabled, not playing');
      return;
    }
    
    try {
      final trackPath = _musicTracks[_currentTrackIndex];
      print('▶️ Playing: $trackPath (Volume: $_currentVolume)');
      
      await _audioPlayer.play(
        AssetSource(trackPath),
        volume: _currentVolume,
      );
      _isPlayingMusic = true;
      print('✅ Music playing successfully');
    } catch (e) {
      print('❌ Error playing music: $e');
      _isPlayingMusic = false;
    }
  }

  /// Play next track in sequence
  Future<void> _playNextTrack() async {
    _currentTrackIndex = (_currentTrackIndex + 1) % _musicTracks.length;
    print('⏭️ Moving to next track: ${_musicTracks[_currentTrackIndex]}');
    await _playCurrentTrack();
  }

  /// Stop music playback
  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    _isPlayingMusic = false;
  }

  /// Pause music
  Future<void> pauseMusic() async {
    await _audioPlayer.pause();
    _isPlayingMusic = false;
  }

  /// Resume music
  Future<void> resumeMusic() async {
    if (_isMusicEnabled) {
      await _audioPlayer.resume();
      _isPlayingMusic = true;
    }
  }

  /// Enable/disable background music
  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;
    
    if (enabled && !_isPlayingMusic) {
      await startMusic();
    } else if (!enabled && _isPlayingMusic) {
      await stopMusic();
    }
  }

  /// Get current music enabled state
  bool isMusicEnabled() {
    return _isMusicEnabled;
  }

  /// Get current playing state
  bool isPlayingMusic() {
    return _isPlayingMusic;
  }

  /// Set music volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _currentVolume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_currentVolume);
  }

  /// Get current volume
  double getVolume() {
    return _currentVolume;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
