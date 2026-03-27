import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/guest_pass_service.dart';

class GuardScannerPage extends StatefulWidget {
  const GuardScannerPage({super.key});

  @override
  State<GuardScannerPage> createState() => _GuardScannerPageState();
}

class _GuardScannerPageState extends State<GuardScannerPage> {
  bool _handled = false;
  String _title = 'Наведите камеру на QR';
  String _subtitle = '';

  void _handleCode(String code) {
    if (_handled) return;

    _handled = true;

    final result = GuestPassService.validatePass(code);

    if (result.isValid) {
      GuestPassService.markUsed(code);
    }

    setState(() {
      _title = result.isValid ? 'ДОСТУП РАЗРЕШЕН' : 'ДОСТУП ЗАПРЕЩЕН';

      final pass = result.pass;
      if (pass != null) {
        _subtitle =
        '${result.message}\n'
            'Гость: ${pass.guestName}\n'
            '${pass.byCar ? "Авто: ${pass.carNumber ?? "-"}" : "Пешком"}';
      } else {
        _subtitle = result.message;
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _handled = false;
        _title = 'Наведите камеру на QR';
        _subtitle = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканер охраны'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: (capture) {
                for (final barcode in capture.barcodes) {
                  final code = barcode.rawValue;
                  if (code != null && code.isNotEmpty) {
                    _handleCode(code);
                    break;
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_subtitle.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}