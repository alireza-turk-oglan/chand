import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import '../models/price_item.dart';

class PriceGrid extends StatelessWidget {
  final List<PriceItem> items;
  final void Function(PriceItem) onLongPress;
  final void Function(int, int) onReorder;

  const PriceGrid({
    super.key,
    required this.items,
    required this.onLongPress,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 3
                : 2;
        final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
        const cardHeight = 160.0;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ReorderableWrap(
            spacing: 16,
            runSpacing: 16,
            padding: const EdgeInsets.all(0),
            onReorder: onReorder,
            children: items.map((item) {
              return SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: GestureDetector(
                  onLongPress: () => onLongPress(item),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.network(item.iconAsset, width: 40, height: 40),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(item.price, style: const TextStyle(fontSize: 18, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
