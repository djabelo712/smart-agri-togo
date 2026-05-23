import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/energy_model.dart';
import '../data/models/system_model.dart';
import 'field_provider.dart';

final systemStreamProvider = StreamProvider<SystemStatus?>((ref) {
  return ref.watch(fieldRepositoryProvider).watchSystem();
});

final energyStreamProvider = StreamProvider<EnergyStatus?>((ref) {
  return ref.watch(fieldRepositoryProvider).watchEnergy();
});
