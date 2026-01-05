import 'package:flutter/material.dart';

class Room {
  // Room colors - customizable through wallpaper/flooring items
  Color leftWallColor;
  Color rightWallColor;
  Color floorColor;

  Room({
    // Default light brown colors (matching SVG)
    this.leftWallColor = const Color(0xFFD4B5A0),
    this.rightWallColor = const Color(0xFFC5A896),
    this.floorColor = const Color(0xFFDCC7B0),
  });

  // Change wall color (when wallpaper item is applied)
  void setWallColor(Color left, Color right) {
    leftWallColor = left;
    rightWallColor = right;
  }

  // Change floor color (when flooring item is applied)
  void setFloorColor(Color color) {
    floorColor = color;
  }
}

