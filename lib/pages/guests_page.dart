import 'package:flutter/material.dart';

import '../models/guest_pass.dart';
import '../services/guest_pass_service.dart';
import 'guest_pass_qr_page.dart';
import 'guard_scanner_page.dart';

class GuestsPage extends StatefulWidget {
  const GuestsPage({super.key});

  @override
  State<GuestsPage> createState() => _GuestsPageState();
}

class _GuestsPageState extends State<GuestsPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _car = TextEditingController();

  DateTime? _from;
  DateTime? _to;
  bool _byCar = true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _car.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isFrom}) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      initialDate: isFrom
          ? (_from ?? now)
          : (_to ?? _from ?? now),
    );
    if (date == null) return;

    final initialTime = isFrom
        ? TimeOfDay.fromDateTime(_from ?? now)
        : TimeOfDay.fromDateTime(_to ?? _from ?? now);

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (time == null) return;

    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isFrom) {
        _from = dt;
        if (_to != null && !_to!.isAfter(_from!)) {
          _to = null;
        }
      } else {
        _to = dt;
      }
    });
  }

  void _createPass() {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final car = _car.text.trim();

    if (name.isEmpty) {
      _showSnack('Введите имя гостя');
      return;
    }

    if (_from == null || _to == null) {
      _showSnack('Выберите время "с" и "по"');
      return;
    }

    if (!_to!.isAfter(_from!)) {
      _showSnack('Время окончания должно быть позже времени начала');
      return;
    }

    if (_byCar && car.isEmpty) {
      _showSnack('Введите номер авто или выключите режим авто');
      return;
    }

    final pass = GuestPass(
      id: 'PASS_${DateTime.now().millisecondsSinceEpoch}',
      guestName: name,
      phone: phone,
      byCar: _byCar,
      carNumber: _byCar ? car : null,
      validFrom: _from!,
      validTo: _to!,
    );

    GuestPassService.addPass(pass);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuestPassQrPage(pass: pass),
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {});
    });

    _name.clear();
    _phone.clear();
    _car.clear();

    setState(() {
      _from = null;
      _to = null;
      _byCar = true;
    });
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _fmt(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d.$m $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final passes = GuestPassService.getAllPasses();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Гости в ЖК'),
        actions: [
          IconButton(
            tooltip: 'Сканер охраны',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GuardScannerPage(),
                ),
              ).then((_) {
                if (!mounted) return;
                setState(() {});
              });
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Оформить пропуск',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Имя гостя',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Телефон (опционально)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _byCar,
                      onChanged: (v) => setState(() => _byCar = v),
                      title: const Text('Гость на авто'),
                    ),
                    if (_byCar) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _car,
                        decoration: const InputDecoration(
                          labelText: 'Номер авто',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _pickDateTime(isFrom: true),
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        _from == null ? 'С: выбрать' : 'С: ${_fmt(_from!)}',
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _from == null
                          ? null
                          : () => _pickDateTime(isFrom: false),
                      icon: const Icon(Icons.schedule_outlined),
                      label: Text(
                        _to == null ? 'По: выбрать' : 'По: ${_fmt(_to!)}',
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _createPass,
                        child: const Text('Создать пропуск'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  'Активные/созданные пропуска',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text('${passes.length}'),
              ],
            ),
            const SizedBox(height: 10),
            if (passes.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Пока пропусков нет'),
                ),
              )
            else
              ...passes.map(
                    (pass) => Card(
                  child: ListTile(
                    title: Text(pass.guestName),
                    subtitle: Text(
                      '${_fmt(pass.validFrom)} - ${_fmt(pass.validTo)}\n'
                          '${pass.byCar ? "Авто: ${pass.carNumber ?? "-"}" : "Пешком"}\n'
                          '${pass.isUsed ? "Статус: использован" : "Статус: активен"}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.qr_code),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GuestPassQrPage(pass: pass),
                          ),
                        ).then((_) {
                          if (!mounted) return;
                          setState(() {});
                        });
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}