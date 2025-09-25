import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_paystack/flutter_paystack.dart';

import '../../constants.dart';

class PaymentService {
  PaymentService() : _plugin = PaystackPlugin();

  final PaystackPlugin _plugin;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized || EnvironmentConfig.paystackPublicKey.isEmpty) {
      return;
    }
    await _plugin.initialize(publicKey: EnvironmentConfig.paystackPublicKey);
    _initialized = true;
  }

  Future<bool> processPayment({
    required String email,
    required double amount,
  }) async {
    await _ensureInitialized();
    final reference = _generateReference();
    final amountInKobo = (amount * 100).round();
    if (EnvironmentConfig.paystackPublicKey.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return true;
    }
    try {
      final charge = Charge()
        ..amount = amountInKobo
        ..email = email
        ..reference = reference;
      final response = await _plugin.checkout(
        charge,
        method: CheckoutMethod.card,
        fullscreen: true,
      );
      return response.status == true;
    } catch (error) {
      debugPrint('Payment error: $error');
      return false;
    }
  }

  String _generateReference() {
    final random = Random.secure();
    return 'WC-${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(99999)}';
  }
}
