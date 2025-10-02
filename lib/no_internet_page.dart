import 'package:flutter/material.dart';

class NoInternetPage extends StatelessWidget {
  final VoidCallback onRetry;
  const NoInternetPage({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "اتصال به اینترنت برقرار نیست",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text("تلاش مجدد"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
