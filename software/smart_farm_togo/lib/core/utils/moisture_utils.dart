import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// Couleur d'humidité volumique θ (m³/m³) — à utiliser partout dans l'UI.
Color moistureColor(double theta) {
  if (theta < 0.12) return const Color(0xFFC62828);
  if (theta < 0.18) return const Color(0xFFE65100);
  if (theta < 0.25) return const Color(0xFF66BB6A);
  if (theta < 0.30) return const Color(0xFF2E7D32);
  return const Color(0xFF0277BD);
}

/// Couleur du traitement expérimental (T1/T2/T3).
Color treatmentColor(String treatment) {
  if (treatment == 'MPC') return AppColors.waterBlue;
  if (treatment == 'PID') return AppColors.alertOrange;
  return const Color(0xFF9E9E9E);
}

/// Coefficient de stress hydrique Ks (alias vers FieldParams).
double stressKs(double theta) => FieldParams.stressKs(theta);

/// Libellé français du niveau d'humidité.
String moistureLabel(double theta) {
  if (theta < 0.12) return 'Sec';
  if (theta < 0.18) return 'Stress';
  if (theta < 0.25) return 'Correct';
  if (theta < 0.30) return 'Optimal';
  return 'Saturé';
}

/// Libellé court du traitement pour les badges AppBar.
String treatmentBadgeLabel(String treatment) {
  switch (treatment) {
    case 'MPC':
      return 'T1';
    case 'PID':
      return 'T2';
    default:
      return 'T3';
  }
}
