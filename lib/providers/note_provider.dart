// Flutter Documentation (Google), (2024) Simple app state management.
//Available at: https://flutter.dev/docs/data-and-backend/state-mgmt/simple
//(Accessed: 28 October 2024).

import 'package:flutter/material.dart';
import '../helpers/note_database_helper.dart';
import '../models/note.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _items = [];

  List<Note> get items => [..._items];

  List<Note> itemsByLabel(String titleLabel) =>
      _items.where((e) => e.label == titleLabel).toList();

  Future fetchAndSet() async {
    _items = await NoteDatabaseHelper.instance.getAllRecords();
    notifyListeners();
  }

  Future add(Note note) async {
    _items.insert(0, note);
    notifyListeners();
    await NoteDatabaseHelper.instance.insertRecord(note);
  }

  Future update(Note note) async {
    final index = _items.indexWhere((e) => e.id == note.id);

    if (index != -1) {
      _items[index] = note;
      notifyListeners();
      await NoteDatabaseHelper.instance.updateRecord(note);
    }
  }

  Future delete(int id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await NoteDatabaseHelper.instance.deleteRecord(id);
  }

  Future deleteAll() async {
    _items.clear();
    notifyListeners();
    await NoteDatabaseHelper.instance.deleteAllRecords();
  }

  Future removeLabelContent({required String content}) async {
    final int n = _items.length;
    for (var i = 0; i < n; i++) {
      if (_items[i].label == content) {
        final newNote = _items[i].copy(label: '');
        _items[i] = newNote;
        await NoteDatabaseHelper.instance.updateRecord(newNote);
      }
    }
    notifyListeners();
  }

  Future removeAllLabelContent() async {
    _items = [..._items.map((e) => e.copy(label: ''))];
    notifyListeners();
    await NoteDatabaseHelper.instance
        .changeFieldValueOfAllRecords(field: NoteField.label, value: '');
  }
}
