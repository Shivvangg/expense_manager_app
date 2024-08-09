import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../models/sidebar_component/menu.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    required this.menu,
    required this.press,
    required this.riveOnInit,
    required this.selectedMenu,
  });

  final Menu menu;
  final VoidCallback press;
  final ValueChanged<Artboard> riveOnInit;
  final Menu? selectedMenu; // Make selectedMenu nullable

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedMenu == menu;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Divider(color: Colors.white24, height: 1),
        ),
        Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              width: isSelected ? 288 : 0, // Expand width if selected
              height: 56,
              left: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF6792FF),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            ListTile(
              onTap: press,
              leading: SizedBox(
                height: 36,
                width: 36,
                child: RiveAnimation.asset(
                  menu.rive.src, // Ensure menu.rive.src points to your Rive animation file
                  artboard: menu.rive.artboard, // Ensure menu.rive.artboard is defined in your Menu model
                  onInit: riveOnInit,
                ),
              ),
              title: Text(
                menu.title,
                style: TextStyle(color: isSelected ? Colors.white : Colors.white70),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
