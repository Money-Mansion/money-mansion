import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/room.dart';

class RoomViewer extends StatelessWidget {
  final Room? room;

  const RoomViewer({
    super.key,
    this.room,
  });

  @override
  Widget build(BuildContext context) {
    if (room == null) {
      return const Center(
        child: Text('No room available'),
      );
    }

    return Container(
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
    );
  }
}
