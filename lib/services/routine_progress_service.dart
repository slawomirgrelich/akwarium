import 'package:shared_preferences/shared_preferences.dart';

class RoutineProgressService {
  RoutineProgressService({this.preferences});

  final SharedPreferences? preferences;

  Future<Set<String>> load(String aquariumId, String templateId) async {
    final store = preferences ?? await SharedPreferences.getInstance();
    return (store.getStringList(_key(aquariumId, templateId)) ?? const [])
        .toSet();
  }

  Future<void> save(
    String aquariumId,
    String templateId,
    Set<String> completedStepIds,
  ) async {
    final store = preferences ?? await SharedPreferences.getInstance();
    await store.setStringList(
      _key(aquariumId, templateId),
      completedStepIds.toList(growable: false),
    );
  }

  String _key(String aquariumId, String templateId) =>
      'routine.progress.${aquariumId.trim()}.$templateId';
}
