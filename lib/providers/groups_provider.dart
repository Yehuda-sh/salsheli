// 📄 File: lib/providers/groups_provider.dart
// 🎯 Purpose: Provider לניהול קבוצות (Groups)
//
// 📋 Features:
// - טעינת קבוצות של המשתמש
// - CRUD לקבוצות
// - ניהול חברים
// - Stream לעדכונים בזמן אמת
// - שילוב עם UserContext
//
// 📝 Version: 1.0
// 📅 Created: 14/12/2025

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/user_role.dart';
import '../models/group.dart';
import '../models/group_invite.dart';
import '../repositories/group_invite_repository.dart';
import '../repositories/group_repository.dart';
import '../services/contact_picker_service.dart';
import 'user_context.dart';

class GroupsProvider with ChangeNotifier {
  final GroupRepository _repository;
  final GroupInviteRepository _inviteRepository;
  final _uuid = const Uuid();

  // State
  List<Group> _groups = [];
  Group? _selectedGroup;
  bool _isLoading = false;
  String? _errorMessage;

  // User Context
  UserContext? _userContext;
  StreamSubscription<List<Group>>? _groupsSubscription;

  GroupsProvider({
    required GroupRepository repository,
    GroupInviteRepository? inviteRepository,
  })
      : _repository = repository,
        _inviteRepository = inviteRepository ?? GroupInviteRepository();

  // === Getters ===

  /// כל הקבוצות של המשתמש
  List<Group> get groups => List.unmodifiable(_groups);

  /// הקבוצה הנבחרת
  Group? get selectedGroup => _selectedGroup;

  /// מצב טעינה
  bool get isLoading => _isLoading;

  /// הודעת שגיאה
  String? get errorMessage => _errorMessage;

  /// האם יש שגיאה
  bool get hasError => _errorMessage != null;

  /// האם אין קבוצות
  bool get isEmpty => _groups.isEmpty;

  /// מספר הקבוצות
  int get groupCount => _groups.length;

  /// קבוצות לפי סוג
  List<Group> getGroupsByType(GroupType type) =>
      _groups.where((g) => g.type == type).toList();

  /// קבוצות משפחה בלבד
  List<Group> get familyGroups => getGroupsByType(GroupType.family);

  /// קבוצות שאני בעלים שלהן
  List<Group> getOwnedGroups(String userId) =>
      _groups.where((g) => g.isOwnerUser(userId)).toList();

  // === User Context Integration ===

  /// עדכון UserContext - נקרא מ-main.dart
  void updateUserContext(UserContext userContext) {
    if (_userContext == userContext) return;

    // 🛡️ הסרת listener מה-context הישן למניעת דליפת זיכרון
    _userContext?.removeListener(_onUserChanged);

    _userContext = userContext;
    _userContext!.addListener(_onUserChanged);

    // טען מיד אם יש משתמש מחובר
    if (_userContext!.isLoggedIn) {
      _startWatchingGroups();
    }
  }

  /// מופעל כאשר UserContext משתנה
  void _onUserChanged() {
    if (_userContext?.isLoggedIn ?? false) {
      _startWatchingGroups();
    } else {
      _stopWatchingGroups();
      _clearState();
    }
  }

  /// התחלת האזנה לקבוצות
  void _startWatchingGroups() {
    final userId = _userContext?.userId;
    if (userId == null) return;

    if (kDebugMode) {
      debugPrint('👁️ GroupsProvider: Starting to watch groups for $userId');
    }

    _groupsSubscription?.cancel();
    _groupsSubscription = _repository.watchUserGroups(userId).listen(
      (groups) {
        _groups = groups;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();

        if (kDebugMode) {
          debugPrint('📥 GroupsProvider: Received ${groups.length} groups');
        }
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();

        if (kDebugMode) {
          debugPrint('❌ GroupsProvider: Error watching groups: $error');
        }
      },
    );

    _isLoading = true;
    notifyListeners();
  }

  /// הפסקת האזנה לקבוצות
  void _stopWatchingGroups() {
    _groupsSubscription?.cancel();
    _groupsSubscription = null;
  }

  /// ניקוי state
  void _clearState() {
    _groups = [];
    _selectedGroup = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // === Load Groups (Manual) ===

  /// טעינת קבוצות (ידנית)
  Future<void> loadGroups() async {
    final userId = _userContext?.userId;
    if (userId == null) {
      if (kDebugMode) {
        debugPrint('⚠️ GroupsProvider.loadGroups: No user logged in');
      }
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('📥 GroupsProvider.loadGroups: Loading for $userId');
      }

      _groups = await _repository.getUserGroups(userId);

      if (kDebugMode) {
        debugPrint('✅ GroupsProvider.loadGroups: Loaded ${_groups.length} groups');
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('❌ GroupsProvider.loadGroups: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === GROUP CRUD ===

  /// יצירת קבוצה חדשה
  Future<Group?> createGroup({
    required String name,
    required GroupType type,
    String? description,
    String? imageUrl,
    Map<String, dynamic>? extraFields,
    List<SelectedContact>? invitedContacts,
  }) async {
    final user = _userContext?.user;
    if (user == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return null;
    }

    try {
      _isLoading = true;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('📝 GroupsProvider.createGroup: $name (${type.hebrewName})');
        if (invitedContacts != null && invitedContacts.isNotEmpty) {
          debugPrint('   📨 Will invite ${invitedContacts.length} contacts');
        }
      }

      final group = Group.create(
        id: 'grp_${_uuid.v4()}',
        name: name,
        type: type,
        description: description,
        imageUrl: imageUrl,
        creatorId: user.id,
        creatorName: user.name,
        creatorEmail: user.email,
        creatorAvatar: user.profileImageUrl,
        extraFields: extraFields,
      );

      final createdGroup = await _repository.createGroup(group);

      // שליחת הזמנות לאנשי הקשר
      if (invitedContacts != null && invitedContacts.isNotEmpty) {
        await _sendInvites(
          group: createdGroup,
          contacts: invitedContacts,
          inviterId: user.id,
          inviterName: user.name,
        );
      }

      // הערה: לא מוסיפים ידנית לרשימה - ה-Stream (watchUserGroups) יעשה זאת אוטומטית

      if (kDebugMode) {
        debugPrint('✅ GroupsProvider.createGroup: Created ${createdGroup.id}');
      }

      return createdGroup;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('❌ GroupsProvider.createGroup: $e');
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// שליחת הזמנות לאנשי קשר
  Future<void> _sendInvites({
    required Group group,
    required List<SelectedContact> contacts,
    required String inviterId,
    required String inviterName,
  }) async {
    for (final contact in contacts) {
      try {
        final invite = GroupInvite.create(
          groupId: group.id,
          groupName: group.name,
          invitedPhone: contact.phone,
          invitedEmail: contact.email,
          invitedName: contact.displayName,
          role: contact.role,
          invitedBy: inviterId,
          invitedByName: inviterName,
        );

        await _inviteRepository.createInvite(invite);

        if (kDebugMode) {
          debugPrint('   ✅ Invite sent to ${contact.displayName}');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('   ❌ Failed to invite ${contact.displayName}: $e');
        }
        // ממשיכים לשלוח לאחרים גם אם אחד נכשל
      }
    }
  }

  /// עדכון קבוצה
  Future<bool> updateGroup(Group group) async {
    try {
      if (kDebugMode) {
        debugPrint('✏️ GroupsProvider.updateGroup: ${group.id}');
      }

      await _repository.updateGroup(group);

      // הערה: לא מעדכנים ידנית - ה-Stream (watchUserGroups) יעשה זאת אוטומטית

      if (kDebugMode) {
        debugPrint('✅ GroupsProvider.updateGroup: Success');
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('❌ GroupsProvider.updateGroup: $e');
      }
      notifyListeners();
      return false;
    }
  }

  /// מחיקת קבוצה
  Future<bool> deleteGroup(String groupId) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ GroupsProvider.deleteGroup: $groupId');
      }

      // מחיקת כל ההזמנות הממתינות של הקבוצה
      try {
        await _inviteRepository.deleteAllGroupInvites(groupId);
      } catch (e) {
        // לא נכשל את כל הפעולה אם מחיקת ההזמנות נכשלה
        if (kDebugMode) {
          debugPrint('⚠️ Failed to delete group invites: $e');
        }
      }

      await _repository.deleteGroup(groupId);

      // הערה: לא מסירים ידנית מהרשימה - ה-Stream יעשה זאת אוטומטית

      // אם הקבוצה הנבחרת נמחקה
      if (_selectedGroup?.id == groupId) {
        _selectedGroup = null;
        notifyListeners();
      }

      if (kDebugMode) {
        debugPrint('✅ GroupsProvider.deleteGroup: Success');
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('❌ GroupsProvider.deleteGroup: $e');
      }
      notifyListeners();
      return false;
    }
  }

  /// בחירת קבוצה
  void selectGroup(String? groupId) {
    if (groupId == null) {
      _selectedGroup = null;
    } else {
      _selectedGroup = _groups.where((g) => g.id == groupId).firstOrNull;
    }
    notifyListeners();
  }

  // === MEMBER MANAGEMENT ===

  /// הוספת חבר לקבוצה
  Future<bool> addMember({
    required String groupId,
    required String userId,
    required String name,
    required String email,
    String? avatarUrl,
    UserRole role = UserRole.editor,
    required String invitedBy,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('➕ GroupsProvider.addMember: $name to $groupId');
      }

      final member = GroupMember.invited(
        userId: userId,
        name: name,
        email: email,
        avatarUrl: avatarUrl,
        role: role,
        invitedBy: invitedBy,
      );

      await _repository.addMember(groupId, member);

      // הערה: לא מעדכנים ידנית - ה-Stream (watchUserGroups) יעשה זאת אוטומטית

      if (kDebugMode) {
        debugPrint('✅ GroupsProvider.addMember: Success');
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('❌ GroupsProvider.addMember: $e');
      }
      notifyListeners();
      return false;
    }
  }

  /// הסרת חבר מקבוצה
  Future<bool> removeMember(String groupId, String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('➖ GroupsProvider.removeMember: $userId from $groupId');
      }

      await _repository.removeMember(groupId, userId);

      // הערה: לא מעדכנים ידנית - ה-Stream (watchUserGroups) יעשה זאת אוטומטית

      if (kDebugMode) {
        debugPrint('✅ GroupsProvider.removeMember: Success');
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('❌ GroupsProvider.removeMember: $e');
      }
      notifyListeners();
      return false;
    }
  }

  /// עדכון תפקיד חבר
  Future<bool> updateMemberRole(
    String groupId,
    String userId,
    UserRole newRole,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔄 GroupsProvider.updateMemberRole: $userId to ${newRole.hebrewName}',
        );
      }

      await _repository.updateMemberRole(groupId, userId, newRole);

      // הערה: לא מעדכנים ידנית - ה-Stream (watchUserGroups) יעשה זאת אוטומטית

      if (kDebugMode) {
        debugPrint('✅ GroupsProvider.updateMemberRole: Success');
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('❌ GroupsProvider.updateMemberRole: $e');
      }
      notifyListeners();
      return false;
    }
  }

  // === UTILS ===

  /// קבלת קבוצה לפי ID
  Group? getGroup(String groupId) {
    return _groups.where((g) => g.id == groupId).firstOrNull;
  }

  /// בדיקה אם המשתמש חבר בקבוצה
  bool isUserMember(String groupId, String userId) {
    final group = getGroup(groupId);
    return group?.isMember(userId) ?? false;
  }

  /// בדיקה אם המשתמש owner של קבוצה
  bool isUserOwner(String groupId, String userId) {
    final group = getGroup(groupId);
    return group?.isOwnerUser(userId) ?? false;
  }

  /// ניקוי הודעת שגיאה
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // === Lifecycle ===

  @override
  void dispose() {
    _stopWatchingGroups();
    _userContext?.removeListener(_onUserChanged);
    super.dispose();
  }
}
