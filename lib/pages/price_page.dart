// price_page.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:http/http.dart' as http;

import '../models/price_item.dart';
import '../services/api_service.dart';
import '../coin_selector.dart';
import '../widgets/price_header.dart';
import '../widgets/price_footer.dart';
import '../widgets/price_grid.dart';

class PricePage extends StatefulWidget {
  const PricePage({Key? key}) : super(key: key);

  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  List<PriceItem> items = [];
  List<String> selectedCoins = [];
  Map<String, dynamic> allCoins = {};
  bool loadingCoins = true;

  @override
  void initState() {
    super.initState();
    loadUserCoins();
  }

  Future<void> loadUserCoins() async {
    final prefs = await SharedPreferences.getInstance();
    selectedCoins = prefs.getStringList("selected_coins") ?? ["USDTIRT"];

    final url = Uri.parse("https://raw.githubusercontent.com/alireza-turk-oglan/chand/refs/heads/main/coinlist/apilist.json");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      allCoins = jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (!mounted) return;
    setState(() => loadingCoins = false);
    await fetchPrices();
  }

  Future<void> saveUserCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("selected_coins", selectedCoins);
  }

  Future<void> fetchPrices() async {
    final List<PriceItem> newItems = [];
    Map<String, dynamic>? findCoin(Map<String, dynamic> map, String symbol) {
      for (final entry in map.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          if (value.containsKey("symbol") && (value["symbol"] == symbol || entry.key == symbol)) {
            return value;
          } else {
            final result = findCoin(value, symbol);
            if (result != null) return result;
          }
        }
      }
      return null;
    }

    for (final symbol in selectedCoins) {
      String displayName = symbol;
      String? img;
      String? api;

      final coin = findCoin(allCoins, symbol);
      if (coin != null) {
        displayName = coin["name"] ?? symbol;
        img = coin["img"];
        api = coin["api"];
      }

      String? price;
      if (api == "nobitex") {
        price = await ApiService.getLastTradePrice(symbol);
      } else if (api == "tgju") {
        price = await ApiService.getItemPrice(symbol);
      }

      final iconUrl = "https://raw.githubusercontent.com/alireza-turk-oglan/chand/refs/heads/main/coinlist/$img";

      newItems.add(PriceItem(
        title: displayName,
        iconAsset: iconUrl,
        price: price != null ? "$price IRT" : "ناموجود",
        symbol: symbol,
      ));
    }

    if (!mounted) return;
    setState(() => items = newItems);
  }


  void showBlurPopup(PriceItem item) {
    final isGold = item.symbol == "GOLD";
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.3 * 255).round()),
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          title: Text(item.title, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(item.iconAsset,width: 60,height: 60,fit: BoxFit.cover,errorBuilder: (_, __, ___) => ClipRRect(borderRadius: BorderRadius.circular(30),
                    child: Image.asset("assets/images/default.png",width: 60,height: 60,fit: BoxFit.cover)
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(item.price,style: const TextStyle(fontSize: 20, color: Colors.green)),
              const Padding(padding: EdgeInsets.only(top: 12),child: Text("Powered by Alireza", style: TextStyle(fontSize: 15, color: Colors.black54))),
            ],
          ),
          actionsAlignment: MainAxisAlignment.start,
          actions: [
            if (!isGold)
              TextButton(
                onPressed: () async {
                  if (selectedCoins.length > 1) {
                    selectedCoins.remove(item.symbol);
                    await saveUserCoins();
                    await fetchPrices();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حداقل یک آیتم باید وجود داشته باشد")));
                  }
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }

  void showAddCoinDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CoinSelector(
          allData: allCoins,
          selectedCoins: selectedCoins,
          onConfirm: (newSelection) async {
            if (!mounted) return;
            setState(() => selectedCoins = newSelection);
            await saveUserCoins();
            await fetchPrices();
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final jNow = now.toJalali();
    final formatter = jNow.formatter;
    final dateTimeText = "${formatter.yyyy}/${formatter.mm}/${formatter.dd} - ""${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    if (loadingCoins) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: PriceHeader(onAddCoin: showAddCoinDialog, dateTimeText: dateTimeText),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchPrices();
          setState(() {});
        },
        child: Column(
          children: [
            Expanded(
              child: PriceGrid(items: items,onLongPress: showBlurPopup,onReorder: (oldIndex, newIndex) {
                  setState(() {
                    final item = items.removeAt(oldIndex);
                    items.insert(newIndex, item);
                    selectedCoins = items.map((e) => e.symbol).toList();
                    saveUserCoins();
                  });
                },
              ),
            ),
            const PriceFooter(),
          ],
        ),
      ),
    );
  }
}
