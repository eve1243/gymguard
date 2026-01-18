import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class SecureUserStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ===============================
  // 🔐 USER SPEICHERN / LADEN (MIT ID)
  // ===============================

  Future<void> saveUser(UserProfile user) async {
    await _storage.write(
      key: 'user_${user.id}',
      value: jsonEncode(user.toJson()),
    );
  }

  Future<UserProfile?> loadUserById(String id) async {
    final data = await _storage.read(key: 'user_$id');
    if (data == null) return null;

    return UserProfile.fromJson(jsonDecode(data));
  }

  Future<void> deleteUserById(String id) async {
    await _storage.delete(key: 'user_$id');
  }

  // ===============================
  // 📋 ALLE USER LADEN (SICHER)
  // ===============================

  Future<List<UserProfile>> loadAllUsers() async {
    final all = await _storage.readAll();
    final users = <UserProfile>[];

    for (final entry in all.entries) {
      if (!entry.key.startsWith('user_')) continue;

      try {
        final json = jsonDecode(entry.value);

        // 🔴 WICHTIG: alte User ohne ID überspringen
        if (json['id'] == null) continue;

        users.add(UserProfile.fromJson(json));
      } catch (_) {
        // defekte / alte Einträge ignorieren
      }
    }

    return users;
  }

  // ===============================
  // ⭐ AKTIVER USER (ID)
  // ===============================

  Future<void> saveActiveUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_user_id', userId);
  }

  Future<String?> loadActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('active_user_id');
  }

  Future<void> clearActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_user_id');
  }
}
