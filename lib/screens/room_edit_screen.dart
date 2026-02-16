import 'package:flutter/material.dart';
import '../models/room.dart';
import '../widgets/room_viewer.dart';

class RoomEditScreen extends StatelessWidget {
  final Room? room;

  const RoomEditScreen({
    super.key,
    this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Room centered on white canvas
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RoomViewer(
                room: room,
                onEditPressed: null, // Disable edit button in edit mode
              ),
            ),
          ),
          // Top-left buttons (Checkmark and X)
          Positioned(
            top: 20,
            left: 20,
            child: Row(
              children: [
                // Checkmark button
                FloatingActionButton(
                  mini: true,
                  heroTag: null,
                  backgroundColor: Colors.purple.shade300,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                const SizedBox(width: 10),
                // X button
                FloatingActionButton(
                  mini: true,
                  heroTag: null,
                  backgroundColor: Colors.pink.shade300,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
