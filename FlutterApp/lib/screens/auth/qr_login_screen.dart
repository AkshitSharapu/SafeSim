import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/app_database.dart';
import '../../models/worker.dart';
import '../../models/worker_identity.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/qr_scanner_widget.dart';
import '../../widgets/worker_badge.dart';

class QrLoginScreen extends ConsumerStatefulWidget {
  const QrLoginScreen({super.key});
  @override
  ConsumerState<QrLoginScreen> createState() => _QrLoginScreenState();
}

class _QrLoginScreenState extends ConsumerState<QrLoginScreen> {
  late Future<List<Worker>> _workers;
  bool _scannerOpen = true;
  @override
  void initState() {
    super.initState();
    _workers = AppDatabase.instance.getAllWorkers();
  }

  Future<void> _processLogin(String code) async {
    if (ref.read(authProvider).isLoading) return;
    final success = await ref.read(authProvider.notifier).loginWithCode(code);
    if (success && mounted) context.go('/home?tab=profile');
  }

  Future<void> _register() async {
    setState(() => _scannerOpen = false);
    final worker = await showDialog<Worker>(context: context,
      barrierDismissible: false, builder: (_) => const _RegisterWorkerDialog());
    if (!mounted) return;
    setState(() { _workers = AppDatabase.instance.getAllWorkers(); });
    if (worker != null) await showWorkerBadge(context, worker);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('SafeSim • Offline workers'), actions: [
        IconButton(onPressed: auth.isLoading ? null : _register,
          tooltip: 'Register worker offline', icon: const Icon(Icons.person_add_alt)),
      ]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Scan your QR. Open your profile.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Profiles, training results and certificates stay on this device. No internet required.'),
        const SizedBox(height: 16),
        if (auth.errorMessage != null) Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Text(auth.errorMessage!, style: const TextStyle(color: Colors.red))),
        if (auth.isLoading) const LinearProgressIndicator(),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Camera scanner'),
          value: _scannerOpen, onChanged: auth.isLoading ? null : (v) => setState(() => _scannerOpen = v)),
        if (_scannerOpen) QRScannerWidget(onScanned: _processLogin,
          promptTitle: 'Scan a SafeSim worker badge', manualHint: 'Worker ID, e.g. WK001')
        else _ManualWorkerEntry(onSubmit: _processLogin),
        const SizedBox(height: 24),
        Row(children: [
          const Expanded(child: Text('Workers on this device', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          TextButton.icon(onPressed: auth.isLoading ? null : _register,
            icon: const Icon(Icons.add), label: const Text('Add worker')),
        ]),
        FutureBuilder<List<Worker>>(future: _workers, builder: (context, snapshot) {
          if (snapshot.hasError) return TextButton(onPressed: () => setState(() {
            _workers = AppDatabase.instance.getAllWorkers();
          }), child: const Text('Could not load workers. Retry'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return Column(children: snapshot.data!.map((worker) => Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(worker.name),
            subtitle: Text('${worker.id} • ${worker.role}\n${worker.department}'),
            isThreeLine: true,
            onTap: auth.isLoading ? null : () => _processLogin(worker.id),
            trailing: IconButton(tooltip: 'Show worker QR', icon: const Icon(Icons.qr_code),
              onPressed: () async {
                setState(() => _scannerOpen = false);
                await showWorkerBadge(context, worker);
              }),
          ))).toList());
        }),
        const SizedBox(height: 12),
        const Text('A QR selects a registered profile; it is not a password. Unknown IDs cannot open another worker’s profile.'),
      ]),
    );
  }
}

class _ManualWorkerEntry extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  const _ManualWorkerEntry({required this.onSubmit});
  @override
  State<_ManualWorkerEntry> createState() => _ManualWorkerEntryState();
}
class _ManualWorkerEntryState extends State<_ManualWorkerEntry> {
  final _controller = TextEditingController();
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: TextField(controller: _controller,
      decoration: const InputDecoration(labelText: 'Worker ID, e.g. WK001'),
      onSubmitted: widget.onSubmit)),
    IconButton(onPressed: () => widget.onSubmit(_controller.text), icon: const Icon(Icons.arrow_forward)),
  ]);
}

class _RegisterWorkerDialog extends StatefulWidget {
  const _RegisterWorkerDialog();
  @override
  State<_RegisterWorkerDialog> createState() => _RegisterWorkerDialogState();
}
class _RegisterWorkerDialogState extends State<_RegisterWorkerDialog> {
  final _form = GlobalKey<FormState>();
  final _id = TextEditingController(), _name = TextEditingController();
  final _role = TextEditingController(), _department = TextEditingController();
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    for (final controller in [_id, _name, _role, _department]) { controller.dispose(); }
    super.dispose();
  }
  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      final worker = await AppDatabase.instance.createWorker(id: _id.text, name: _name.text,
        role: _role.text, department: _department.text);
      if (mounted) Navigator.pop(context, worker);
    } catch (error) {
      if (mounted) setState(() { _saving = false;
        _error = error is FormatException ? error.message : 'Could not save worker. Please retry.'; });
    }
  }
  @override
  Widget build(BuildContext context) => PopScope(canPop: !_saving, child: AlertDialog(
    title: const Text('Register worker offline'),
    content: SingleChildScrollView(child: Form(key: _form, child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Give each worker a unique ID. A QR badge is generated after saving.'),
      TextFormField(controller: _id, maxLength: 40, textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(labelText: 'Worker ID (e.g. WK004)'),
        validator: (v) { try { WorkerIdentity.normalize(v ?? ''); return null; }
          on FormatException catch (e) { return e.message; } }),
      for (final field in [(_name, 'Full name'), (_role, 'Role'), (_department, 'Department')])
        TextFormField(controller: field.$1, maxLength: 120,
          decoration: InputDecoration(labelText: field.$2),
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
      if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
    ]))),
    actions: [TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Create profile & QR'))],
  ));
}
