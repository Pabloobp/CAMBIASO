import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _loading = true;

  // Datos de ejemplo (hasta que conectemos Supabase)
  List<Map<String, dynamic>> _rows = [
    {
      'title': 'Limpieza dental',
      'date': '2025-01-10',
      'detail': 'Limpieza completa realizada sin incidencias.',
      'patient_name': 'Paciente Demo',
    },
    {
      'title': 'Empaste',
      'date': '2025-01-05',
      'detail': 'Empaste en molar superior derecho.',
      'patient_name': 'Paciente Demo',
    },
  ];

  bool get _isDentist => true; // Por ahora siempre dentista

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    // Simulación de carga
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _isDentist ? 'Historial médico global' : 'Historial de tratamientos',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_rows.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Sin tratamientos registrados'),
              ),
            )
          else
            ..._rows.map(
                  (row) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(row['title']),
                  subtitle: Text(
                    _isDentist
                        ? '${row['patient_name']} · ${row['date']}\n${row['detail']}'
                        : '${row['date']}\n${row['detail']}',
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
