import '../models/price_item.dart';

class PriceService {
  static final PriceService _instance = PriceService._internal();
  factory PriceService() => _instance;
  PriceService._internal();

  List<PriceItem> _items = [];

  List<PriceItem> get items => _items;

  void updateItems(List<PriceItem> newItems) {
    _items = newItems;
  }
}
