/// Données analytiques simulées (7 derniers jours).
class AnalyticsMock {
  AnalyticsMock._();

  /// Humidité volumique moyenne du champ (m³/m³) par jour.
  static const List<double> moistureAvg7Days = [
    0.22,
    0.24,
    0.23,
    0.25,
    0.21,
    0.26,
    0.24,
  ];

  /// Volume d'irrigation journalier (mm).
  static const List<double> waterDaily7Days = [
    5.2,
    4.8,
    6.1,
    5.6,
    4.2,
    5.0,
    4.2,
  ];

  static double get waterWeekTotal =>
      waterDaily7Days.fold(0.0, (a, b) => a + b);

  static const double waterManuelWeekAvg = 38.0;
  static const double waterMpcWeekAvg = 32.0;

  static int get waterSavingsPercent =>
      ((1 - waterMpcWeekAvg / waterManuelWeekAvg) * 100).round();

  static const List<Map<String, dynamic>> cropYields = [
    {
      'crop': 'Oignon',
      'yield_t_ha': 18.5,
      'status': 'Bon',
    },
    {
      'crop': 'Carotte',
      'yield_t_ha': 14.2,
      'status': 'Moyen',
    },
    {
      'crop': 'Laitue',
      'yield_t_ha': 8.6,
      'status': 'Faible',
    },
    {
      'crop': 'Maïs',
      'yield_t_ha': 4.8,
      'status': 'Moyen',
    },
  ];

  static const double estimatedNetRevenueFcfa = 1_245_000;
  static const double globalHydricSatisfaction = 0.87;
}
