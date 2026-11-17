import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backup_providers.dart';

/// Dispara el respaldo automático al abrir la app y al volver a ella.
class AutoBackupHook extends ConsumerStatefulWidget {
  const AutoBackupHook({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AutoBackupHook> createState() => _AutoBackupHookState();
}

class _AutoBackupHookState extends ConsumerState<AutoBackupHook> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(autoBackupProvider).runIfDue());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.read(autoBackupProvider).runIfDue();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
