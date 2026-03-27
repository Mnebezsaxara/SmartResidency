import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/guest_pass.dart';

class GuestPassQrPage extends StatelessWidget {
  final GuestPass pass;

  const GuestPassQrPage({
    super.key,
    required this.pass,
  });

  String _fmt(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.$y  $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR-пропуск'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Гостевой пропуск',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pass.guestName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (pass.phone.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(pass.phone),
                    ],
                    const SizedBox(height: 20),
                    QrImageView(
                      data: pass.id,
                      size: 220,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Код: ${pass.id}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text('С: ${_fmt(pass.validFrom)}'),
                    Text('По: ${_fmt(pass.validTo)}'),
                    const SizedBox(height: 8),
                    Text(
                      pass.byCar
                          ? 'На авто: ${pass.carNumber ?? "-"}'
                          : 'Пешком',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}