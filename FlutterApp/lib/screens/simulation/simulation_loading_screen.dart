import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/simulation_bridge.dart';
import '../../services/simulation_launcher_service.dart';
import '../../providers/progress_provider.dart';

class SimulationLoadingScreen extends ConsumerStatefulWidget {
  final String workerId, moduleId;
  const SimulationLoadingScreen({super.key, required this.workerId, required this.moduleId});
  @override
  ConsumerState<SimulationLoadingScreen> createState() => _SimulationLoadingScreenState();
}
class _SimulationLoadingScreenState extends ConsumerState<SimulationLoadingScreen> {
  String? _error;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _launch(); });
  }
  Future<void> _launch() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      final result = await SimulationLauncherService.instance.launchSimulation(
        workerId: widget.workerId, moduleId: widget.moduleId);
      await ref.read(progressProvider.notifier).refreshActiveWorker();
      if (mounted) context.go('/results', extra: result);
    } on SimulationCancelled {
      if (mounted) setState(() => _error = 'Training was closed. No completion was recorded.');
    } catch (e) {
      if (mounted) setState(() => _error = e is SimulationUnavailable ? e.message : 'The session result could not be saved or validated. Please retry.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      backgroundColor: const Color(0xFF09121F),
      appBar: AppBar(title: const Text('Fire response training'), automaticallyImplyLeading: !_busy),
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.local_fire_department_outlined, size: 80, color: Color(0xFF42A5F5)),
          const SizedBox(height: 24),
          Text(_error == null ? 'Opening your training session' : 'Training is not running',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(_error ?? 'The factory simulation will open full screen. Your results will return here when you finish.',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 28),
          if (_busy) const CircularProgressIndicator()
          else ...[
            FilledButton.icon(onPressed: _launch, icon: const Icon(Icons.refresh), label: const Text('Try again')),
            TextButton(onPressed: () => context.go('/home'), child: const Text('Back to dashboard')),
          ],
        ]),
      ))),
    ),
  );
}
