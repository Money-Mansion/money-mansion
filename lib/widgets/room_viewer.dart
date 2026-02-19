import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/room.dart';

class RoomViewer extends StatelessWidget {
  final Room? room;
  final VoidCallback? onEditPressed;

  const RoomViewer({
    super.key,
    this.room,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (room == null) {
      return const Center(
        child: Text('No room available'),
      );
    }

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0), // Add space around SVG
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF5),
            border: Border.all(
              color: const Color(0xFFB8A8D8),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/images/room.svg',
              width: 400,
              height: 400,
            ),
            // TODO: Item placement system will go here as Flutter widgets
            // Items will be rendered as draggable widgets on top of the room SVG
          ),
        ),
        // Edit button (bottom-right corner)
        if (onEditPressed != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                mini: true,
                heroTag: null,
                backgroundColor: Colors.purple.shade300,
                onPressed: onEditPressed,
                child: const Icon(Icons.edit, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
