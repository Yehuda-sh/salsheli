// lib/core/household_naming.dart — Neutral household naming helper — generates "MemoZap-XXXX" fallback

import 'dart:math';

const _kHouseholdNamePrefix = 'MemoZap';
const int _kRandomSuffixMin = 1000;
const int _kRandomSuffixRange = 9000;

/// Generates a neutral default household name (e.g. "MemoZap-7042").
///
/// Used as the fallback when the user has not chosen a name yet, OR when
/// they skip the post-registration dialog. Stays neutral on purpose — the
/// app is not only for nuclear families (see CLAUDE.md `Audience & Voice`).
String generateDefaultHouseholdName() {
  final suffix = _kRandomSuffixMin + Random().nextInt(_kRandomSuffixRange);
  return '$_kHouseholdNamePrefix-$suffix';
}
