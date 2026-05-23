import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/control_repository.dart';
import 'alert_provider.dart';

final controlControllerProvider =
    StateNotifierProvider<ControlController, AsyncValue<void>>((ref) {
  return ControlController(ref.watch(controlRepositoryProvider));
});

class ControlController extends StateNotifier<AsyncValue<void>> {
  ControlController(this._repository) : super(const AsyncData(null));

  final ControlRepository _repository;

  Future<void> openValve(String cellId, {int durationMin = 15}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.openValve(cellId, durationMin: durationMin),
    );
  }

  Future<void> closeValve(String cellId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.closeValve(cellId));
  }

  Future<void> startPump({int durationMin = 30}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.startPump(durationMin: durationMin),
    );
  }

  Future<void> stopPump() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.stopPump);
  }

  Future<void> setMode(String mode) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.setMode(mode));
  }
}
