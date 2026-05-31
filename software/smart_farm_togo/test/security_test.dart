import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farm_togo/core/constants/app_constants.dart';
import 'package:smart_farm_togo/core/errors/app_exception.dart';
import 'package:smart_farm_togo/core/utils/api_url_utils.dart';
import 'package:smart_farm_togo/data/datasources/api_datasource.dart';

void main() {
  group('Validation ApiDatasource', () {
    late ApiDatasource api;

    setUp(() {
      api = ApiDatasource(baseUrl: AppConstants.defaultApiBaseUrl);
    });

    test('cellId invalide rejeté', () async {
      expect(
        () => api.controlValve(cell: 'Z99', action: 'open'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('ks_daily trop court rejeté', () async {
      expect(
        () => api.getYieldForecastForCell(
          cropName: 'Oignon',
          ksDailyValues: [0.5, 0.6],
          treatment: 'MPC',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('culture invalide rejetée', () async {
      expect(
        () => api.getYieldForecastForCell(
          cropName: 'Tomate',
          ksDailyValues: List<double>.filled(10, 0.8),
          treatment: 'MPC',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Ks hors plage rejeté', () async {
      expect(
        () => api.getYieldForecastForCell(
          cropName: 'Oignon',
          ksDailyValues: List<double>.filled(10, 1.5),
          treatment: 'MPC',
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('URL API', () {
    test('normalise https et retire le slash final', () {
      expect(
        normalizeApiBaseUrl('smart-agri-togo.onrender.com/'),
        'https://smart-agri-togo.onrender.com',
      );
    });
  });

  group('Constantes sécurité', () {
    test('URL API production configurée', () {
      expect(
        AppConstants.defaultApiBaseUrl,
        'https://smart-agri-togo.onrender.com',
      );
    });

    test('cultures valides définies', () {
      expect(AppConstants.validCropNames, contains('Oignon'));
      expect(AppConstants.validCropNames, contains('Maïs'));
    });
  });
}
