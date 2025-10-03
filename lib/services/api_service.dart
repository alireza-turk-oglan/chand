import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiService {
  static Future<String?> getItemPrice(String itemId) async {
    try {
      final url = Uri.parse("https://api.tgju.org/v1/widget/tmp?keys=$itemId");
      final response = await http.get(
        url,
        headers: {"Accept": "application/json", "User-Agent": "Flutter-http"},
      );

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      final indicator = data['response']['indicators'][0];
      double? price;

      if (indicator.containsKey('p_irr')) {
        price = double.tryParse(indicator['p_irr'].toString().replaceAll(',', ''));
      } else if (indicator.containsKey('p')) {
        price = double.tryParse(indicator['p'].toString().replaceAll(',', ''));
      }

      if (price != null) {
        price = price / 10;
        final formatter = NumberFormat.decimalPattern('en');
        return formatter.format(price);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getLastTradePrice(String pair) async {
    try {
      final url = Uri.parse("https://apiv2.nobitex.ir/v3/orderbook/$pair");
      final response = await http.get(url);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final priceRaw = data['lastTradePrice'];

      if (priceRaw != null) {
        final price = double.tryParse(priceRaw.toString());
        if (price != null) {
          final formatter = NumberFormat.decimalPattern('en');
          return formatter.format(price / 10);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
