import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

/// Réinitialise le délai de session à chaque interaction utilisateur.
class SessionActivityScope extends ConsumerWidget {
  const SessionActivityScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        ref.read(sessionTimeoutProvider.notifier).recordActivity();
      },
      child: child,
    );
  }
}
