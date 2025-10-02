import 'package:flutter/material.dart';

class PriceHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAddCoin;

  const PriceHeader({super.key, required this.onAddCoin});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Chand?"),
      actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: onAddCoin)
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
