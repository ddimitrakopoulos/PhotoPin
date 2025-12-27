import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../generated/assets.dart';
import '../domain/memory.dart';

class MemoryLocalDataSource {
  static const _keyMemories = 'memories_v1';

  Future<List<Memory>> loadMemories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyMemories);

    if (raw == null) {
      final seeded = _seedMemories();
      await saveMemories(seeded);
      return seeded;
    }

    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Memory.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveMemories(List<Memory> memories) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(memories.map((m) => m.toJson()).toList());
    await prefs.setString(_keyMemories, raw);
  }

  /// Dummy data – with geo coordinates
  List<Memory> _seedMemories() {
    return [
      Memory(
        id: '1',
        title: 'Φυση και τα σχετικα',
        date: DateTime(2025, 7, 12),
        location: 'Zographou, Athens, Greece',
        imageAsset: Assets.imagesDummyImage1,
        lat: 35.5175,
        lng: 24.0193,
      ),
      Memory(
        id: '2',
        title: 'Στο σπιτι της γιαγιας',
        date: DateTime(2025, 6, 16),
        location: 'Zographou, Athens, Greece',
        imageAsset: Assets.imagesDummyImage2,
        lat: 35.5183,
        lng: 24.0192,
      ),
      Memory(
        id: '3',
        title: 'Ωραιος τοιχος',
        date: DateTime(2025, 5, 30),
        location: 'Ilisia, Athens, Greece',
        imageAsset: Assets.imagesDummyImage3,
        lat: 35.517872951914,
        lng: 24.019746974694044,
      ),
      Memory(
        id: '4',
        title: 'Ειχα μεθυσει',
        date: DateTime(2025, 5, 24),
        location: 'Ilisia, Athens, Greece',
        imageAsset: Assets.imagesDummyImage4,
        lat: 35.5173,
        lng: 24.0201,
      ),
    ];
  }
}
