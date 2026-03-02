import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../models/room.dart';
import '../games/room_world.dart';

class RoomViewer extends StatefulWidget {
  final Room? room;
  final VoidCallback? onEditPressed;

  const RoomViewer({
    super.key,
    this.room,
    this.onEditPressed,
  });

  @override
  State<RoomViewer> createState() => _RoomViewerState();
}

class _RoomViewerState extends State<RoomViewer> {
  late RoomWorld roomWorld;

  @override
  void initState() {
    super.initState();
    roomWorld = RoomWorld();
  }

  @override
  void dispose() {
    roomWorld.pauseEngine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.room == null) {
      return const Center(
        child: Text('No room available'),
      );
    }

    return Stack(
      children: [
        // Flame canvas filling the entire space
        SizedBox.expand(
          child: GameWidget(
            game: roomWorld,
          ),
        ),
        // Chrumko guide (top-right corner)
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16.0, 0.0, 0),
            child: Image.asset(
              'assets/images/chrumko.png',
              width: 150,
              height: 150,
            ),
          ),
        ),
        // Edit button (bottom-right corner)
        if (widget.onEditPressed != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                mini: true,
                heroTag: null,
                backgroundColor: Colors.purple.shade300,
                onPressed: widget.onEditPressed,
                child: const Icon(Icons.edit, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
