import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class CoinSelector extends StatefulWidget {
  final Map<String, dynamic> allData;
  final List<String> selectedCoins;
  final ValueChanged<List<String>> onConfirm;

  const CoinSelector({
    super.key,
    required this.allData,
    required this.selectedCoins,
    required this.onConfirm,
  });

  @override
  State<CoinSelector> createState() => _CoinSelectorState();
}

class _CoinSelectorState extends State<CoinSelector> {
  late List<String> tempSelected;
  String search = "";
  List<String> navigationStack = [];

  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.selectedCoins);
    logger.i("Init CoinSelector with selectedCoins : ${widget.selectedCoins}");
  }

  dynamic getCurrentData() {
    dynamic data = widget.allData;
    for (var key in navigationStack) {
      data = data[key];
    }
    return data;
  }

  bool isCoinNode(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.containsKey("symbol") && value.containsKey("name");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final currentData = getCurrentData();

    Widget body;

    if (currentData is Map<String, dynamic>) {
      final entries = currentData.entries.toList();

      final filtered = entries.where((e) {
        if (isCoinNode(e.value)) {
          final name = e.value["name"]?.toString() ?? e.key;
          return name.toLowerCase().contains(search.toLowerCase());
        } else {
          return e.key.toLowerCase().contains(search.toLowerCase());
        }
      }).toList();

      body = Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: "جستجو...",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              logger.i("Search changed: $value");
              setState(() => search = value);
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final entry = filtered[index];
                if (isCoinNode(entry.value)) {
                  // کوین
                  final symbol = entry.value["symbol"].toString();
                  final name = entry.value["name"] ?? entry.key;
                  final isSelected = tempSelected.contains(symbol);
                  final alreadySelected = widget.selectedCoins.contains(symbol);

                  return ListTile(
                    leading: Image.network(
                      "https://raw.githubusercontent.com/alireza-turk-oglan/Price-list/refs/heads/main/coinlist/${entry.value["img"]}",
                      width: 30,
                      height: 30,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 30),
                    ),
                    title: Text(
                      name,
                      style: alreadySelected ? const TextStyle(color: Colors.grey) : null,
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: alreadySelected
                          ? null
                          : (val) {
                              logger.i("Checkbox changed : $symbol -> $val");
                              setState(() {
                                if (val == true) {
                                  tempSelected.add(symbol);
                                } else {
                                  tempSelected.remove(symbol);
                                }
                              });
                            },
                    ),
                    onTap: alreadySelected
                        ? null
                        : () {
                            logger.i("Tile tapped : $symbol");
                            setState(() {
                              if (isSelected) {
                                tempSelected.remove(symbol);
                              } else {
                                tempSelected.add(symbol);
                              }
                            });
                          },
                  );
                } else {
                  // زیردسته
                  return ListTile(
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      logger.i("Navigate into category : ${entry.key}");
                      setState(() {
                        navigationStack.add(entry.key);
                      });
                    },
                  );
                }
              },
            ),
          ),
        ],
      );
    } else {
      body = const Center(child: Text("دیتا نامعتبر است"));
    }

    return PopScope(
      canPop: navigationStack.isEmpty,
      onPopInvokedWithResult: (result, didPop) async {
        logger.i("Pop invoked, didPop: $didPop , stack: $navigationStack");

        if ((didPop ?? false) == false && navigationStack.isNotEmpty) {
          setState(() {
            navigationStack.removeLast();
          });
          logger.i("Back to parent category");
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            if (navigationStack.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  logger.i("Back button pressed");
                  setState(() {
                    navigationStack.removeLast();
                  });
                },
              ),
            Text(navigationStack.isEmpty ? "انتخاب دسته‌بندی" : navigationStack.last),
          ],
        ),
        content: SizedBox(width: double.maxFinite, height: 400, child: body),
        actions: [
          TextButton(
            onPressed: () {
              logger.i("Confirm pressed, selectedCoins: $tempSelected");
              widget.onConfirm(tempSelected);
              Navigator.of(context).pop();
            },
            child: const Text("تایید"),
          ),
        ],
      ),
    );
  }
}
