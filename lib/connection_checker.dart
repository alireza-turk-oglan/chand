// connection_checker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '/pages/price_page.dart';
import 'no_internet_page.dart';

class ConnectionChecker extends StatefulWidget {
  const ConnectionChecker({super.key});

  @override
  State<ConnectionChecker> createState() => _ConnectionCheckerState();
}

class _ConnectionCheckerState extends State<ConnectionChecker> {
  bool checking = true;
  bool connected = false;

  Future<void> checkConnection() async {
    setState(() {
      checking = true;
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      final hasInternet = await _hasNetwork();

      setState(() {
        connected = hasInternet;
        checking = false;
      });
    } else {
      setState(() {
        connected = false;
        checking = false;
      });
    }
  }

  Future<bool> _hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    if (checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (connected) {
      return const PricePage();
    }

    return NoInternetPage(onRetry: checkConnection);
  }
}
