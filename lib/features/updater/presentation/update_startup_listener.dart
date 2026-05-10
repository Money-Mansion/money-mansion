import 'package:flutter/material.dart';

import '../domain/update_service.dart';

class UpdateStartupListener extends StatefulWidget {
  final Widget child;

  const UpdateStartupListener({
    super.key,
    required this.child,
  });

  @override
  State<UpdateStartupListener> createState() => _UpdateStartupListenerState();
}

class _UpdateStartupListenerState extends State<UpdateStartupListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateService.instance.maybeCheckOnStartup(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateService.instance.maybeCheckOnStartup(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
