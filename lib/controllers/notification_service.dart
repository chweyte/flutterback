import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationItem {
  final String title;
  final String body;
  final String time;
  bool read;
  final String iconType;

  NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.read,
    required this.iconType,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'body': body,
    'time': time,
    'read': read,
    'iconType': iconType,
  };

  factory NotificationItem.fromMap(Map<String, dynamic> map) =>
      NotificationItem(
        title: map['title'] ?? '',
        body: map['body'] ?? '',
        time: map['time'] ?? '',
        read: map['read'] ?? false,
        iconType: map['iconType'] ?? 'info',
      );
}

class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  List<NotificationItem> _items = [];
  List<NotificationItem> get items => _items;
  bool get hasUnread => _items.any((elem) => !elem.read);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('notifications');
    if (str != null) {
      final List dec = jsonDecode(str);
      _items = dec.map((e) => NotificationItem.fromMap(e)).toList();
    } else {
      _items = [];
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final enc = jsonEncode(_items.map((e) => e.toMap()).toList());
    await prefs.setString('notifications', enc);
    notifyListeners();
  }

  Future<void> addNotification(NotificationItem item) async {
    _items.insert(0, item);
    await _save();
  }

  Future<void> markAsRead(int index) async {
    if (index >= 0 && index < _items.length && !_items[index].read) {
      _items[index].read = true;
      await _save();
    }
  }

  Future<void> clearAll() async {
    _items.clear();
    await _save();
  }
}
