import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/weather_model.dart';
import 'field_provider.dart';

final weatherStreamProvider = StreamProvider<Weather?>((ref) {
  return ref.watch(fieldRepositoryProvider).watchWeather();
});

final forecastStreamProvider = StreamProvider<FieldForecast?>((ref) {
  return ref.watch(fieldRepositoryProvider).watchForecast();
});
