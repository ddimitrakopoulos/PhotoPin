import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/memory.dart';

class MemoryLocalDataSource {
  static const _keyMemories = 'memories_v2';

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
    
    // Use setString and verify the save succeeded
    final success = await prefs.setString(_keyMemories, raw);
    
    if (!success) {
      throw Exception('Failed to save memories to SharedPreferences');
    }
    
    // Force commit on Android (especially important for Samsung devices)
    // This ensures the data is written to disk immediately
    await prefs.reload();
  }

  /// Start with empty memories - user adds their own
  List<Memory> _seedMemories() {
    return [];
  }
}
