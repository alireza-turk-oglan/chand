import 'package:flutter/material.dart';

class PriceHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAddCoin;
  final String dateTimeText;

  const PriceHeader({
    super.key,
    required this.onAddCoin,
    required this.dateTimeText,
  });

  @override
  Size get preferredSize => const Size.fromHeight(85);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 85,
      actions: [IconButton(icon: const Icon(Icons.add),onPressed: onAddCoin)],
      title: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Chand?",style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold,color: Color.fromARGB(179, 0, 0, 0))),
          Text(dateTimeText,style: const TextStyle(fontSize: 25,color: Color.fromARGB(179, 0, 0, 0))),
        ],
      ),
    );
  }
}
