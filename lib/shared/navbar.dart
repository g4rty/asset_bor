import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const Color _bg = Colors.black;
  static const Color _active = Color.fromARGB(255, 210, 245, 160);
  static const Color _inactive = Colors.white;

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home,
      Icons.shopping_bag_outlined,
      Icons.list_alt_outlined,
      Icons.history,
    ];
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: 72 + bottomInset,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottomInset > 0 ? bottomInset * 0.4 : 12,
      ),
      color: _bg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (i) {
          final selected = i == index;
          return InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? _active : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icons[i],
                size: 24,
                color: selected ? Colors.black : _inactive,
              ),
            ),
          );
        }),
      ),
    );
  }
}
