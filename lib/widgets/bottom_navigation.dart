import 'package:flutter/material.dart';
import '../my_flutter_app_icons.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F7), // Soft cream/beige background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(
          color: const Color(0xFFB8A8D8), // Soft purple border
          width: 3,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavButton(
              key: const Key('nav_button_0'),
              icon: MyFlutterApp.house,
              color: const Color(0xFFE89BAC), // Soft pink
              isSelected: selectedIndex == 0,
              onTap: () => onItemTapped(0),
            ),
            _NavButton(
              key: const Key('nav_button_1'),
              icon: MyFlutterApp.shop,
              color: const Color(0xFFB8D98E), // Soft green
              isSelected: selectedIndex == 1,
              onTap: () => onItemTapped(1),
            ),
            _NavButton(
              key: const Key('nav_button_2'),
              icon: MyFlutterApp.house,
              color: const Color(0xFFF2C48D), // Soft peach
              isSelected: selectedIndex == 2,
              onTap: () => onItemTapped(2),
            ),
            _NavButton(
              key: const Key('nav_button_3'),
              icon: MyFlutterApp.task,
              color: const Color.fromARGB(255, 157, 204, 224), // clue
              isSelected: selectedIndex == 3,
              onTap: () => onItemTapped(3),
            ),
            _NavButton(
              key: const Key('nav_button_4'),
              icon: MyFlutterApp.man,
              color: const Color.fromARGB(255, 239, 187, 199), // Soft pink
              isSelected: selectedIndex == 4,
              onTap: () => onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final Widget icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    super.key,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.25) : Colors.white.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: icon,
          ),
        ),
      ),
    );
  }
}
