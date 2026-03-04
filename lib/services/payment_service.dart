import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  // Payoneer API Credentials (আপনার আসল credentials দিন)
  static const String _payoneerApiKey = "YOUR_PAYONEER_API_KEY";
  static const String _payoneerSecretKey = "YOUR_PAYONEER_SECRET_KEY";
  static const String _payoneerProgramId = "YOUR_PROGRAM_ID";

  // পেমেন্ট স্ট্যাটাস ট্র্যাক করার জন্য callback
  final Function(String status, String message)? onPaymentUpdate;

  PaymentService({this.onPaymentUpdate});

  // 1️⃣ Payoneer পেমেন্ট প্রসেস
  Future<Map<String, dynamic>> processPayoneerPayment({
    required double amount,
    required String currency,
    required String orderId,
    required String customerEmail,
    String? customerName,
  }) async {
    try {
      onPaymentUpdate?.call('processing', 'Payoneer payment initializing...');

      // Payoneer API endpoint
      final url = Uri.parse(
        'https://api.payoneer.com/v2/programs/$_payoneerProgramId/payments',
      );

      // পেমেন্ট ডেটা
      final paymentData = {
        'amount': amount,
        'currency': currency,
        'orderId': orderId,
        'customerEmail': customerEmail,
        'customerName': customerName ?? 'Donor',
        'description': 'Donation for Islamic App',
        'paymentMethod': 'payoneer',
        'redirectUrl': 'youra//payment-callback', // Deep link
        'webhookUrl': 'https://yourserver.com/webhook/payoneer',
      };

      // API Request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_payoneerApiKey',
          'X-Secret-Key': _payoneerSecretKey,
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        onPaymentUpdate?.call('success', 'Payment initiated');

        return {
          'success': true,
          'paymentUrl': data['paymentUrl'],
          'transactionId': data['transactionId'],
          'status': 'pending',
        };
      } else {
        onPaymentUpdate?.call('error', 'Payment initialization failed');
        return {'success': false, 'error': 'Failed to initialize payment'};
      }
    } catch (e) {
      onPaymentUpdate?.call('error', 'Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // 2️⃣ Visa/Mastercard Card পেমেন্ট (Stripe দিয়ে)
  Future<Map<String, dynamic>> processCardPayment({
    required double amount,
    required String currency,
    required String cardNumber,
    required String cardHolder,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String orderId,
    required String customerEmail,
  }) async {
    try {
      onPaymentUpdate?.call('processing', 'Card payment processing...');

      // Stripe API (Payoneer card processing এর জন্য)
      final url = Uri.parse('https://api.stripe.com/v1/payment_intents');

      // পেমেন্ট ইন্টেন্ট তৈরি
      final paymentIntent = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer YOUR_STRIPE_SECRET_KEY',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).toInt().toString(), // cent এ কনভার্ট
          'currency': currency.toLowerCase(),
          'payment_method_types[]': 'card',
          'description': 'Donation - $orderId',
          'metadata[orderId]': orderId,
          'metadata[customerEmail]': customerEmail,
        },
      );

      if (paymentIntent.statusCode == 200) {
        final intentData = json.decode(paymentIntent.body);

        // কার্ড পেমেন্ট কনফার্ম
        final confirmPayment = await http.post(
          Uri.parse(
            'https://api.stripe.com/v1/payment_intents/${intentData['id']}/confirm',
          ),
          headers: {
            'Authorization': 'Bearer YOUR_STRIPE_SECRET_KEY',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'payment_method[type]': 'card',
            'payment_method[card][number]': cardNumber,
            'payment_method[card][exp_month]': expiryMonth,
            'payment_method[card][exp_year]': expiryYear,
            'payment_method[card][cvc]': cvv,
            'payment_method[billing_details][name]': cardHolder,
            'payment_method[billing_details][email]': customerEmail,
            'return_url': 'youra//payment-success',
          },
        );

        if (confirmPayment.statusCode == 200) {
          final confirmData = json.decode(confirmPayment.body);

          if (confirmData['status'] == 'succeeded') {
            onPaymentUpdate?.call('success', 'Payment successful!');
            return {
              'success': true,
              'transactionId': confirmData['id'],
              'amount': amount,
              'status': 'completed',
            };
          } else {
            return {
              'success': false,
              'error': 'Payment not completed',
              'requires_action': confirmData['next_action'],
            };
          }
        }
      }

      return {'success': false, 'error': 'Payment failed'};
    } catch (e) {
      onPaymentUpdate?.call('error', 'Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // 3️⃣ পেমেন্ট স্ট্যাটাস চেক
  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    try {
      final url = Uri.parse(
        'https://api.payoneer.com/v2/transactions/$transactionId',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_payoneerApiKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'amount': data['amount'],
          'currency': data['currency'],
          'completedAt': data['completedAt'],
        };
      }

      return {'success': false, 'error': 'Transaction not found'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // 4️⃣ ওয়েবহুক হ্যান্ডলার (সার্ভার থেকে callback)
  void handleWebhook(String payload) {
    try {
      final data = json.decode(payload);

      switch (data['event']) {
        case 'payment.succeeded':
          onPaymentUpdate?.call('success', 'Payment completed');
          break;
        case 'payment.failed':
          onPaymentUpdate?.call('error', 'Payment failed');
          break;
        case 'payment.pending':
          onPaymentUpdate?.call('pending', 'Payment pending');
          break;
      }
    } catch (e) {
      debugPrint('Webhook error: $e');
    }
  }
}
