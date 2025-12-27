import 'package:flutter/foundation.dart';

import '../../data/memory_local_data_source.dart';
import '../../domain/memory.dart';

class MemoriesController extends ChangeNotifier {
  MemoriesController(this._localDataSource);

  final MemoryLocalDataSource _localDataSource;

  List<Memory> _memories = [];
  bool _isLoading = true;

  List<Memory> get memories => _memories;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _memories = await _localDataSource.loadMemories();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMemory(Memory memory) async {
    _memories = [memory, ..._memories];
    await _localDataSource.saveMemories(_memories);
    notifyListeners();
  }

  Future<void> updateMemories(List<Memory> updated) async {
    _memories = updated;
    await _localDataSource.saveMemories(_memories);
    notifyListeners();
  }

  /// Delete a single memory by instance
  Future<void> deleteMemory(Memory memory) async {
    _memories = _memories.where((m) => m.id != memory.id).toList();
    await _localDataSource.saveMemories(_memories);
    notifyListeners();
  }

  /// Delete a single memory by id
  Future<void> deleteMemoryById(String id) async {
    _memories = _memories.where((m) => m.id != id).toList();
    await _localDataSource.saveMemories(_memories);
    notifyListeners();
  }

  /// Delete all memories
  Future<void> clearAll() async {
    _memories = [];
    await _localDataSource.saveMemories(_memories);
    notifyListeners();
  }
}
