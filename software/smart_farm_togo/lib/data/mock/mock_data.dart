import '../models/alert_model.dart';
import '../models/cell_model.dart';
import '../models/energy_model.dart';
import '../models/history_model.dart';
import '../models/system_model.dart';
import '../models/weather_model.dart';

/// Données simulées pour le mode démo (sans Firebase).
class MockData {
  MockData._();

  static final List<FieldCell> mockCells = [
    const FieldCell(id: 'C00', theta: 0.25, treatment: 'MPC', crop: 'Oignon', valveOpen: false, stressKs: 0.94),
    const FieldCell(id: 'C01', theta: 0.28, treatment: 'MPC', crop: 'Oignon', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C02', theta: 0.32, treatment: 'MPC', crop: 'Oignon', valveOpen: true, stressKs: 1.0),
    const FieldCell(id: 'C03', theta: 0.17, treatment: 'PID', crop: 'Oignon', valveOpen: false, stressKs: 0.44),
    const FieldCell(id: 'C04', theta: 0.22, treatment: 'PID', crop: 'Oignon', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C10', theta: 0.29, treatment: 'MPC', crop: 'Oignon', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C11', theta: 0.34, treatment: 'MPC', crop: 'Oignon', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C12', theta: 0.26, treatment: 'MPC', crop: 'Oignon', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C13', theta: 0.15, treatment: 'PID', crop: 'Oignon', valveOpen: false, stressKs: 0.63),
    const FieldCell(id: 'C14', theta: 0.20, treatment: 'PID', crop: 'Oignon', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C20', theta: 0.30, treatment: 'MPC', crop: 'Carotte', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C21', theta: 0.27, treatment: 'MPC', crop: 'Carotte', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C22', theta: 0.25, treatment: 'MPC', crop: 'Carotte', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C23', theta: 0.23, treatment: 'PID', crop: 'Carotte', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C24', theta: 0.28, treatment: 'PID', crop: 'Carotte', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C30', theta: 0.11, treatment: 'PID', crop: 'Laitue', valveOpen: false, stressKs: 0.13),
    const FieldCell(id: 'C31', theta: 0.25, treatment: 'PID', crop: 'Laitue', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C32', theta: 0.29, treatment: 'PID', crop: 'Laitue', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C33', theta: 0.31, treatment: 'Manuel', crop: 'Laitue', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C34', theta: 0.26, treatment: 'Manuel', crop: 'Laitue', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C40', theta: 0.22, treatment: 'Manuel', crop: 'Maïs', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C41', theta: 0.19, treatment: 'Manuel', crop: 'Maïs', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C42', theta: 0.27, treatment: 'Manuel', crop: 'Maïs', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C43', theta: 0.30, treatment: 'Manuel', crop: 'Maïs', valveOpen: false, stressKs: 1.0),
    const FieldCell(id: 'C44', theta: 0.24, treatment: 'Manuel', crop: 'Maïs', valveOpen: false, stressKs: 1.0),
  ];

  static Map<String, FieldCell> get mockCellsMap =>
      {for (final c in mockCells) c.id: c};

  static final Weather mockWeather = Weather(
    timestamp: DateTime.utc(2025, 11, 14, 8),
    tempC: 32.1,
    humidityPct: 38.0,
    solarRadWm2: 720.0,
    windSpeedMs: 2.4,
    rainfallMm: 0.0,
    et0MmDay: 8.3,
  );

  static final FieldForecast mockForecast = const FieldForecast(
    et0Next7Days: [8.1, 8.4, 7.9, 8.6, 8.2, 8.0, 8.5],
    rainNext7Days: [0.0, 0.0, 2.1, 0.0, 0.0, 0.0, 0.0],
  );

  static final SystemStatus mockSystem = SystemStatus(
    pumpRunning: false,
    controllerMode: 'MPC',
    lastHeartbeat: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
    activeValvesCount: 1,
    dailyWaterUsedMm: 4.2,
    dailyWaterBudgetMm: 8.0,
  );

  static final EnergyStatus mockEnergy = const EnergyStatus(
    batterySocPct: 87.0,
    solarPowerW: 540.0,
    loadPowerW: 85.0,
    dailyGenerationKwh: 3.2,
    dailyConsumptionKwh: 1.8,
  );

  static final List<FarmAlert> mockAlerts = [
    FarmAlert(
      id: 'alert1',
      type: 'stress',
      cell: 'C30',
      message: 'Zone C30 en stress hydrique critique (θ=0.11 < θp=0.18)',
      severity: 'critical',
      timestamp: DateTime.utc(2025, 11, 14, 7, 45),
      acknowledged: false,
    ),
  ];

  static final List<DailyHistory> mockHistory = [
    const DailyHistory(
      date: '2025-11-13',
      totalIrrigationMm: 5.6,
      avgStressKs: 0.91,
      et0Mm: 8.1,
      rainMm: 0.0,
    ),
  ];
}
