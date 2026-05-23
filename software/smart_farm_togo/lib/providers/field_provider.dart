import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/firebase/firebase_bootstrap.dart';
import '../data/datasources/firebase_datasource.dart';
import '../data/models/cell_model.dart';
import '../data/repositories/field_repository.dart';
import 'settings_provider.dart';

final firebaseDatasourceProvider = Provider<FirebaseDatasource?>((ref) {
  if (!firebaseAvailable) return null;
  return FirebaseDatasource();
});

final fieldRepositoryProvider = Provider<FieldRepository>((ref) {
  final demo = ref.watch(demoModeProvider);
  return FieldRepository(
    firebase: ref.watch(firebaseDatasourceProvider),
    demoMode: demo,
  );
});

final cellsStreamProvider = StreamProvider<Map<String, FieldCell>>((ref) {
  return ref.watch(fieldRepositoryProvider).watchCells();
});

final cellsListProvider = Provider<List<FieldCell>>((ref) {
  final cells = ref.watch(cellsStreamProvider);
  return cells.maybeWhen(
    data: (map) => map.values.toList()..sort((a, b) => a.id.compareTo(b.id)),
    orElse: () => [],
  );
});

final selectedCellProvider = StateProvider<FieldCell?>((ref) => null);

/// Affichage optimiste de l'état vanne avant confirmation API.
final valveOptimisticProvider =
    StateProvider<Map<String, bool>>((ref) => {});
