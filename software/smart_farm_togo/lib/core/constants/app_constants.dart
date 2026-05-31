/// Paramètres physiques du champ — valeurs fixes (non modifiables par l'utilisateur).
class FieldParams {
  FieldParams._();

  static const double thetaWp = 0.10;
  static const double thetaP = 0.18;
  static const double thetaFc = 0.30;
  static const double thetaSat = 0.45;
  static const double rootDepthMm = 300.0;

  static double stressKs(double theta) {
    if (theta >= thetaP) return 1.0;
    if (theta <= thetaWp) return 0.0;
    return (theta - thetaWp) / (thetaP - thetaWp);
  }
}

/// Disposition du champ 25×25 m (grille 5×5).
class FieldLayout {
  FieldLayout._();

  static const int rows = 5;
  static const int cols = 5;
  static const double cellSideM = 5.0;
  static const int totalCells = 25;

  static String cellId(int row, int col) => 'C$row$col';

  static String cropForCell(String cellId) {
    const crops = <String, String>{
      'C00': 'Oignon',
      'C01': 'Oignon',
      'C02': 'Oignon',
      'C03': 'Oignon',
      'C04': 'Oignon',
      'C10': 'Oignon',
      'C11': 'Oignon',
      'C12': 'Oignon',
      'C13': 'Oignon',
      'C14': 'Oignon',
      'C20': 'Carotte',
      'C21': 'Carotte',
      'C22': 'Carotte',
      'C23': 'Carotte',
      'C24': 'Carotte',
      'C30': 'Laitue',
      'C31': 'Laitue',
      'C32': 'Laitue',
      'C33': 'Laitue',
      'C34': 'Laitue',
      'C40': 'Maïs',
      'C41': 'Maïs',
      'C42': 'Maïs',
      'C43': 'Maïs',
      'C44': 'Maïs',
    };
    return crops[cellId] ?? 'Inconnu';
  }

  static List<String> get allCellIds => List.generate(
        rows,
        (r) => List.generate(cols, (c) => cellId(r, c)),
      ).expand((e) => e).toList();
}

/// Constantes applicatives diverses.
class AppConstants {
  AppConstants._();

  static const String appName = 'SmartFarm Togo';
  static const String appVersion = '1.0.0';
  static const String locationLabel = 'Lomé, Togo';
  static const String footerOrg = 'AgroLab Africa';

  /// Heartbeat considéré hors ligne après 5 minutes.
  static const Duration offlineThreshold = Duration(minutes: 5);

  static const String defaultApiBaseUrl =
      'https://smart-agri-togo.onrender.com';

  static const Duration apiConnectTimeout = Duration(seconds: 10);
  static const Duration apiReceiveTimeout = Duration(seconds: 30);
  static const Duration apiSendTimeout = Duration(seconds: 10);

  /// Render.com : le 1er appel après inactivité peut prendre jusqu'à ~60 s.
  static const Duration apiHealthConnectTimeout = Duration(seconds: 60);
  static const Duration apiHealthReceiveTimeout = Duration(seconds: 60);
  static const Duration sessionTimeout = Duration(minutes: 30);

  static const List<String> validCropNames = [
    'Oignon',
    'Carotte',
    'Laitue',
    'Maïs',
  ];

  static const List<String> controllerModes = ['MPC', 'PID', 'Manuel'];
}
