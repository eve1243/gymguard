import 'package:flutter/material.dart';

class LocalizationManager {
  static const String langCode = 'uk'; // Default to Ukrainian

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'GymGuard Rehab',
      'welcome': 'Welcome, Veteran',
      'calibration': 'Body Calibration',
      'reps': 'REPS',
      'good_rep': 'GOOD REP',
      'go_lower': 'GO LOWER',
      'hold': 'HOLD',
      'inhale': 'INHALE',
      'exhale': 'EXHALE',
      'squat_title': 'Leg Rehab',
      'squat_desc': 'Strength & Balance',
      'breathing_title': 'Tactical Breathing',
      'breathing_desc': 'PTSD / Anxiety Relief',
    },
    'uk': {
      'app_title': 'GymGuard: Відновлення',
      'welcome': 'Вітаємо, Захисник',
      'calibration': 'Налаштування Травм', // More respectful than "Calibration"
      'reps': 'ПОВТОРІВ',
      'good_rep': 'ЧУДОВО',
      'go_lower': 'НИЖЧЕ',
      'hold': 'ТРИМАТИ',
      'inhale': 'ВДИХ (4с)',
      'exhale': 'ВИДИХ (4с)',
      'squat_title': 'Реабілітація Ніг',
      'squat_desc': 'Баланс та Сила Кукси',
      'breathing_title': 'Тактичне Дихання',
      'breathing_desc': 'Зняття стресу (ПТСР)',
    },
  };

  static String get(String key) {
    return _localizedValues[langCode]?[key] ?? key;
  }
}