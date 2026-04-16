import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _day = DateTime.now();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  // Simulación del rol (antes venía de SQLite)
  final bool _isDentist = true; // cámbialo a false para modo paciente

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    // Simulación de datos (antes venían de SQLite)
    await Future.delayed(const Duration(milliseconds: 400));

    _items = [
      {
        'id': 1,
        'date': '2025-01-10',
        'hour': '10:00',
        'reason': 'Limpieza dental',
        'status': 'pending',
        'patient_name': 'Juan Pérez',
      },
      {
        'id': 2,
        'date': '2025-01-10',
        'hour': '12:00',
        'reason': 'Revisión',
        'status': 'confirmed',
        'patient_name': 'María López',
      },
      {
        'id': 3,
        'date': '2025-01-11',
        'hour': '09:00',
        'reason': 'Empaste',
        'status': 'completed',
        'patient_name': 'Carlos Ruiz',
      },
    ];

    setState(() => _loading = false);
  }

  Future<void> _pickDay() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _day,
    );
    if (selected == null) return;
    setState(() => _day = selected);
    await _load();
  }

  Future<void> _requestAppointment() async {
    final reasonCtrl = TextEditingController();
    DateTime date = DateTime.now().add(const Duration(days: 1));
    String? slot = "10:00";

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Solicitar cita',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final pick = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 180)),
                    initialDate: date,
                  );
                  if (pick == null) return;
                  setState(() => date = pick);
                },
                icon: const Icon(Icons.event),
                label: Text(date.toIso8601String().split('T').first),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: slot,
                items: const [
                  DropdownMenuItem(value: "10:00", child: Text("10:00")),
                  DropdownMenuItem(value: "11:00", child: Text("11:00")),
                  DropdownMenuItem(value: "12:00", child: Text("12:00")),
                ],
                decoration: const InputDecoration(labelText: 'Horario'),
                onChanged: (value) => slot = value,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(labelText: 'Motivo'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (reasonCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Indica el motivo')),
                    );
                    return;
                  }
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
      },
    );

    reasonCtrl.dispose();
    await _load();
  }

  Future<void> _changeStatus(Map<String, dynamic> row, String status) async {
    setState(() {
      row['status'] = status;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final dayText = _day.toIso8601String().split('T').first;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _isDentist ? 'Citas del día' : 'Mis citas',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _pickDay,
                icon: const Icon(Icons.calendar_today),
                label: Text(dayText),
              ),
            ],
          ),

          if (!_isDentist) ...[
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _requestAppointment,
              icon: const Icon(Icons.add),
              label: const Text('Solicitar nueva cita'),
            ),
          ],

          const SizedBox(height: 12),

          if (_isDentist)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _pill('Total', _items.length.toString()),
                    _pill(
                        'Pendientes',
                        _items
                            .where((e) => e['status'] == 'pending')
                            .length
                            .toString()),
                    _pill(
                        'Confirmadas',
                        _items
                            .where((e) => e['status'] == 'confirmed')
                            .length
                            .toString()),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          if (_loading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator()))
          else if (_items.isEmpty)
            const Card(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay citas para mostrar')))
          else
            ..._items.map(
                  (row) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text('${row['hour']} · ${row['reason']}'),
                  subtitle: Text(
                    _isDentist
                        ? '${row['patient_name']} · ${_statusLabel(row['status'])}'
                        : '${row['date']} · ${_statusLabel(row['status'])}',
                  ),
                  trailing: _isDentist
                      ? PopupMenuButton<String>(
                    onSelected: (value) => _changeStatus(row, value),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'confirmed', child: Text('Confirmar')),
                      PopupMenuItem(
                          value: 'cancelled', child: Text('Cancelar')),
                      PopupMenuItem(
                          value: 'completed', child: Text('Completar')),
                    ],
                  )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$label: $value'),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmada';
      case 'cancelled':
        return 'Cancelada';
      case 'completed':
        return 'Completada';
      default:
        return status;
    }
  }
}
