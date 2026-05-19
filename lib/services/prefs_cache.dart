// lib/services/prefs_cache.dart — Synchronous SharedPreferences accessor.

import 'package:shared_preferences/shared_preferences.dart';

/// Synchronous accessor to SharedPreferences.
///
/// `SharedPreferences.getInstance()` is async, which forces every widget
/// that reads user preferences (dismiss flags, onboarding state, locale
/// hints, etc.) to do a 1-microtask wait on first build — visible as a
/// layout flash where the widget renders empty then suddenly populates.
///
/// `init()` is called once during app bootstrap (before `runApp`) so any
/// later read via [instance] is synchronous. Widgets should still handle
/// `instance == null` as a fallback for paths that didn't bootstrap (e.g.
/// widget tests that pump directly).
class PrefsCache {
  PrefsCache._();

  static SharedPreferences? _instance;

  /// Pre-warm the cache. Idempotent — safe to call multiple times.
  static Future<void> init() async {
    _instance ??= await SharedPreferences.getInstance();
  }

  /// Returns the cached instance, or null if [init] hasn't completed.
  /// Use null-aware reads at call sites that may run before bootstrap.
  static SharedPreferences? get instance => _instance;
}
