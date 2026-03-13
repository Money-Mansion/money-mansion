# Background Music Setup Guide

## Overview
The Money Mansion app now includes a background music system that:
- Plays MP3 files randomly from a list of tracks
- Can be toggled on/off from the Settings screen
- Automatically cycles through tracks when one finishes
- Has adjustable volume (currently set to 0.5 for background playback)

## Adding Your Music Files

1. **Place your MP3 files** in this directory (`assets/music/`)
   - Example: `track1.mp3`, `track2.mp3`, `track3.mp3`

2. **Update the music service** to include your tracks:
   - Open `lib/main.dart`
   - Find the `musicService.initializeTracks()` call
   - Update the list with your actual MP3 file names:
   ```dart
   musicService.initializeTracks([
     'assets/music/your_track1.mp3',
     'assets/music/your_track2.mp3',
     'assets/music/your_track3.mp3',
   ]);
   ```

3. **Run the app**:
   - The music will start automatically when the app launches (if enabled)
   - Users can toggle it from Settings > Game Preferences > Background Music

## Music Service Features

### Methods Available in `MusicService`:

- `startMusic()` - Start playing with a random track
- `stopMusic()` - Stop playback completely
- `pauseMusic()` - Pause the current track
- `resumeMusic()` - Resume from pause
- `setMusicEnabled(bool)` - Enable/disable music (respects user settings)
- `setVolume(double)` - Set volume (0.0 to 1.0)
- `isMusicEnabled()` - Check if music is enabled
- `isPlayingMusic()` - Check if music is currently playing

### Customization Options:

In `lib/services/music_service.dart`, you can adjust:
- **Volume**: Change the `volume: 0.5` parameter in `_playCurrentTrack()` method
- **Track list**: Dynamically add/remove tracks or shuffle them
- **Looping behavior**: Modify the `_playNextTrack()` method

## Integration Points

The music system integrates with:
1. **GameState** - Stores the `musicEnabled` setting (persisted to database)
2. **Settings Screen** - Toggle to enable/disable music
3. **Game Screen** - Starts/stops music based on app state
4. **Localizations** - English and Slovak translations included

## Troubleshooting

- **Music not playing**: Ensure MP3 files are in `assets/music/` and referenced correctly in `main.dart`
- **Volume too loud/quiet**: Adjust the `volume` parameter in `music_service.dart`
- **App crashes on startup**: Check that all referenced MP3 files exist

## Dependencies

The music system uses the `audioplayers` package (^6.0.0), already added to `pubspec.yaml`.
