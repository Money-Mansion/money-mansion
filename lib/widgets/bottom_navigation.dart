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
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(
          top: BorderSide(color: Colors.grey[400]!, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavButton(
            key: const Key('nav_button_0'),
            icon: MyFlutterApp.basket,
            color: Colors.green[600]!,
            isSelected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          _NavButton(
            key: const Key('nav_button_1'),
            icon: MyFlutterApp.money,
            color: Colors.purple[400]!,
            isSelected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),
          _NavButton(
            key: const Key('nav_button_2'),
            icon: MyFlutterApp.home,
            color: Colors.brown[400]!,
            isSelected: selectedIndex == 2,
            onTap: () => onItemTapped(2),
          ),
          _NavButton(
            key: const Key('nav_button_3'),
            icon: MyFlutterApp.target,
            color: Colors.red[400]!,
            isSelected: selectedIndex == 3,
            onTap: () => onItemTapped(3),
          ),
          _NavButton(
            key: const Key('nav_button_4'),
            icon: MyFlutterApp.user,
            color: Colors.blue[400]!,
            isSelected: selectedIndex == 4,
            onTap: () => onItemTapped(4),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
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
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : Colors.grey[400]!,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 32,
        ),
      ),
    );
  }
}