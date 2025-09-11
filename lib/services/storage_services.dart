import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static SharedPreferences? _preferences;

  // Keys
  static const String _userProfileKey = 'user_profile';
  static const String _appSettingsKey = 'app_settings';
  static const String _chatMessagesKey = 'chat_messages';
  static const String _selfNotesKey = 'self_notes';
  static const String _emergencyTipsKey = 'emergency_tips';
  static const String _healthMilestonesKey = 'health_milestones';
  static const String _isFirstTimeKey = 'is_first_time';

  // Initialize service
  static Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Generic methods
  static Future<bool> _setString(String key, String value) async {
    return await _preferences?.setString(key, value) ?? false;
  }

  static String? _getString(String key) {
    return _preferences?.getString(key);
  }

  static Future<bool> _setBool(String key, bool value) async {
    return await _preferences?.setBool(key, value) ?? false;
  }

  static bool _getBool(String key, {bool defaultValue = false}) {
    return _preferences?.getBool(key) ?? defaultValue;
  }

  // First time check
  static Future<bool> isFirstTime() async {
    return _getBool(_isFirstTimeKey, defaultValue: true);
  }

  static Future<void> setNotFirstTime() async {
    await _setBool(_isFirstTimeKey, false);
  }

  // User Profile
  static Future<bool> saveUserProfile(UserProfile profile) async {
    final json = jsonEncode(profile.toJson());
    return await _setString(_userProfileKey, json);
  }

  static UserProfile? getUserProfile() {
    final json = _getString(_userProfileKey);
    if (json != null) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return UserProfile.fromJson(map);
      } catch (e) {
        print('Error decoding user profile: $e');
        return null;
      }
    }
    return null;
  }

  static Future<bool> deleteUserProfile() async {
    return await _preferences?.remove(_userProfileKey) ?? false;
  }

  // App Settings
  static Future<bool> saveAppSettings(AppSettings settings) async {
    final json = jsonEncode(settings.toJson());
    return await _setString(_appSettingsKey, json);
  }

  static AppSettings getAppSettings() {
    final json = _getString(_appSettingsKey);
    if (json != null) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return AppSettings.fromJson(map);
      } catch (e) {
        print('Error decoding app settings: $e');
        return AppSettings(); // Return default settings
      }
    }
    return AppSettings(); // Return default settings
  }

  // Chat Messages
  static Future<bool> saveChatMessages(List<ChatMessage> messages) async {
    final jsonList = messages.map((msg) => msg.toJson()).toList();
    final json = jsonEncode(jsonList);
    return await _setString(_chatMessagesKey, json);
  }

  static List<ChatMessage> getChatMessages() {
    final json = _getString(_chatMessagesKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        return list.map((item) => ChatMessage.fromJson(item)).toList();
      } catch (e) {
        print('Error decoding chat messages: $e');
        return [];
      }
    }
    return [];
  }

  static Future<bool> addChatMessage(ChatMessage message) async {
    final messages = getChatMessages();
    messages.add(message);
    return await saveChatMessages(messages);
  }

  static Future<bool> clearChatMessages() async {
    return await _preferences?.remove(_chatMessagesKey) ?? false;
  }

  // Self Notes
  static Future<bool> saveSelfNotes(List<SelfNote> notes) async {
    final jsonList = notes.map((note) => note.toJson()).toList();
    final json = jsonEncode(jsonList);
    return await _setString(_selfNotesKey, json);
  }

  static List<SelfNote> getSelfNotes() {
    final json = _getString(_selfNotesKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        return list.map((item) => SelfNote.fromJson(item)).toList();
      } catch (e) {
        print('Error decoding self notes: $e');
        return [];
      }
    }
    return [];
  }

  static Future<bool> addSelfNote(SelfNote note) async {
    final notes = getSelfNotes();
    notes.insert(0, note); // Add to beginning
    return await saveSelfNotes(notes);
  }

  static Future<bool> updateSelfNote(String noteId, SelfNote updatedNote) async {
    final notes = getSelfNotes();
    final index = notes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      notes[index] = updatedNote;
      return await saveSelfNotes(notes);
    }
    return false;
  }

  static Future<bool> deleteSelfNote(String noteId) async {
    final notes = getSelfNotes();
    notes.removeWhere((note) => note.id == noteId);
    return await saveSelfNotes(notes);
  }

  // Emergency Tips
  static Future<bool> saveEmergencyTips(List<EmergencyTip> tips) async {
    final jsonList = tips.map((tip) => tip.toJson()).toList();
    final json = jsonEncode(jsonList);
    return await _setString(_emergencyTipsKey, json);
  }

  static List<EmergencyTip> getEmergencyTips() {
    final json = _getString(_emergencyTipsKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        return list.map((item) => EmergencyTip.fromJson(item)).toList();
      } catch (e) {
        print('Error decoding emergency tips: $e');
        return _getDefaultEmergencyTips();
      }
    }
    return _getDefaultEmergencyTips();
  }

  // Health Milestones
  static Future<bool> saveHealthMilestones(List<HealthMilestone> milestones) async {
    final jsonList = milestones.map((milestone) => milestone.toJson()).toList();
    final json = jsonEncode(jsonList);
    return await _setString(_healthMilestonesKey, json);
  }

  static List<HealthMilestone> getHealthMilestones() {
    final json = _getString(_healthMilestonesKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        return list.map((item) => HealthMilestone.fromJson(item)).toList();
      } catch (e) {
        print('Error decoding health milestones: $e');
        return _getDefaultHealthMilestones();
      }
    }
    return _getDefaultHealthMilestones();
  }

  static Future<bool> updateHealthMilestone(String milestoneId, HealthMilestone updatedMilestone) async {
    final milestones = getHealthMilestones();
    final index = milestones.indexWhere((milestone) => milestone.id == milestoneId);
    if (index != -1) {
      milestones[index] = updatedMilestone;
      return await saveHealthMilestones(milestones);
    }
    return false;
  }

  // Progress Stats (calculated based on user profile)
  static ProgressStats? getProgressStats() {
    final profile = getUserProfile();
    if (profile == null) return null;

    final now = DateTime.now();
    final timeDifference = now.difference(profile.quitDate);
    final smokeFreeMinutes = timeDifference.inMinutes;

    // Calculate cigarettes avoided
    final cigarettesPerHour = profile.dailyCigarettes / 24.0;
    final cigarettesAvoided = (smokeFreeMinutes / 60.0 * cigarettesPerHour).round();

    // Calculate money saved
    final moneySaved = cigarettesAvoided * profile.cigarettePrice;

    // Get achieved milestones
    final allMilestones = getHealthMilestones();
    final achievedMilestones = allMilestones
        .where((milestone) => smokeFreeMinutes >= milestone.minutesFromQuit)
        .toList();

    // Calculate health score (0-100 based on achievements)
    final totalMilestones = allMilestones.length;
    final achievedCount = achievedMilestones.length;
    final healthScore = totalMilestones > 0 ? (achievedCount / totalMilestones * 100) : 0.0;

    return ProgressStats(
      quitDate: profile.quitDate,
      cigarettesAvoided: cigarettesAvoided,
      moneySaved: moneySaved,
      smokeFreeMinutes: smokeFreeMinutes,
      achievedMilestones: achievedMilestones,
      healthScore: healthScore,
    );
  }

  // Clear all data
  static Future<bool> clearAllData() async {
    final keys = [
      _userProfileKey,
      _appSettingsKey,
      _chatMessagesKey,
      _selfNotesKey,
      _emergencyTipsKey,
      _healthMilestonesKey,
    ];

    bool success = true;
    for (final key in keys) {
      final result = await _preferences?.remove(key) ?? false;
      if (!result) success = false;
    }

    // Reset first time flag
    await _setBool(_isFirstTimeKey, true);

    return success;
  }

  // Default data
  static List<EmergencyTip> _getDefaultEmergencyTips() {
    return [
      EmergencyTip(
        id: '1',
        title: 'Deep Breathing Exercise',
        description: 'Breathe in for 4 seconds, hold for 4 seconds, breathe out for 4 seconds',
        iconName: 'air',
        colorHex: '#2196F3',
        durationSeconds: 60,
        category: TipCategory.breathing,
        priority: 1,
      ),
      EmergencyTip(
        id: '2',
        title: 'Drink Cold Water',
        description: 'Drink a glass of cold water slowly to help reduce cravings',
        iconName: 'local_drink',
        colorHex: '#00BCD4',
        durationSeconds: 30,
        category: TipCategory.physical,
        priority: 2,
      ),
      EmergencyTip(
        id: '3',
        title: 'Take a Walk',
        description: 'Go for a 5-10 minute walk or do light physical activity',
        iconName: 'directions_walk',
        colorHex: '#4CAF50',
        durationSeconds: 300,
        category: TipCategory.physical,
        priority: 2,
      ),
      EmergencyTip(
        id: '4',
        title: 'Keep Your Hands Busy',
        description: 'Hold something, write, draw, or do any activity that keeps your hands occupied',
        iconName: 'pan_tool',
        colorHex: '#FF9800',
        durationSeconds: 90,
        category: TipCategory.physical,
        priority: 3,
      ),
      EmergencyTip(
        id: '5',
        title: 'Remember Your Motivations',
        description: 'Think about the reasons that made you decide to quit smoking',
        iconName: 'favorite',
        colorHex: '#E91E63',
        durationSeconds: 45,
        category: TipCategory.mental,
        priority: 1,
      ),
    ];
  }

  static List<HealthMilestone> _getDefaultHealthMilestones() {
    return [
      HealthMilestone(
        id: '1',
        title: '20 Minutes',
        description: 'Heart rate and blood pressure drop',
        minutesFromQuit: 20,
        iconName: 'favorite',
        colorHex: '#FF5722',
      ),
      HealthMilestone(
        id: '4',
        title: '48 Hours',
        description: 'Nerve endings start regrowing, taste and smell improve',
        minutesFromQuit: 2880,
        iconName: 'restaurant',
        colorHex: '#FF9800',
      ),
      HealthMilestone(
        id: '5',
        title: '72 Hours',
        description: 'Nicotine is completely eliminated from body',
        minutesFromQuit: 4320,
        iconName: 'check_circle',
        colorHex: '#4CAF50',
      ),
      HealthMilestone(
        id: '6',
        title: '2-12 Weeks',
        description: 'Circulation improves and lung function increases',
        minutesFromQuit: 20160, // 2 weeks
        iconName: 'airline_seat_recline_normal',
        colorHex: '#9C27B0',
      ),
      HealthMilestone(
        id: '7',
        title: '1-9 Months',
        description: 'Coughing and shortness of breath decrease',
        minutesFromQuit: 43200, // 1 month
        iconName: 'healing',
        colorHex: '#607D8B',
      ),
      HealthMilestone(
        id: '8',
        title: '1 Year',
        description: 'Risk of coronary heart disease is half that of a smoker',
        minutesFromQuit: 525600, // 1 year
        iconName: 'celebration',
        colorHex: '#FFC107',
      ),
    ];
  }
}