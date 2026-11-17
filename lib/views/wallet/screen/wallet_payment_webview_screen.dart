import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../controller/wallet_controller.dart';

class WalletPaymentWebviewScreen extends StatefulWidget {
  const WalletPaymentWebviewScreen({super.key});

  @override
  State<WalletPaymentWebviewScreen> createState() =>
      _WalletPaymentWebviewScreenState();
}

class _WalletPaymentWebviewScreenState extends State<WalletPaymentWebviewScreen> {
  late final String paymentUrl;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    paymentUrl = arguments is Map<String, dynamic>
        ? (arguments['url']?.toString() ?? '')
        : '';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _startPolling();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet Payment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _startPolling();
              Get.back();
            },
          ),
        ),
        body: paymentUrl.isEmpty
            ? const Center(child: Text('Payment URL not found'))
            : InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(paymentUrl)),
              ),
      ),
    );
  }

  void _startPolling() {
    if (Get.isRegistered<WalletController>()) {
      Get.find<WalletController>().startPollingAfterPayment();
    }
  }
}
