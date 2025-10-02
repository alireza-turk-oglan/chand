import 'package:flutter/material.dart';

class PriceFooter extends StatelessWidget {
  const PriceFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          "Powered by Alireza",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
