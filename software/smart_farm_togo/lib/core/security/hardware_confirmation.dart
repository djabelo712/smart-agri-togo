import 'package:flutter/material.dart';

import '../../widgets/confirm_dialog.dart';

/// Double confirmation pour actions irréversibles (vannes, pompe, mode Manuel).
Future<bool> requireDoubleConfirmation(
  BuildContext context, {
  required String action,
  required String detail,
}) async {
  final first = await showConfirmDialog(
    context: context,
    title: 'Confirmer : $action',
    message: detail,
    confirmLabel: 'Continuer',
    isDanger: true,
  );
  if (first != true || !context.mounted) return false;

  await Future<void>.delayed(const Duration(seconds: 2));
  if (!context.mounted) return false;

  final second = await showConfirmDialog(
    context: context,
    title: 'Confirmation finale',
    message:
        'Appuyer sur CONFIRMER exécutera immédiatement : $action',
    confirmLabel: 'CONFIRMER',
    isDanger: true,
  );
  return second == true;
}
