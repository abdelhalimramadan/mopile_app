// User Profile Model
class UserProfile {
  final String id;
  final DateTime quitDate;
  final int dailyCigarettes;
  final double cigarettePrice;
  final List<String> motivations;
  final String personalReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.quitDate,
    required this.dailyCigarettes,
    required this.cigarettePrice,
    required this.motivations,
    required this.personalReason,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quitDate': quitDate.toIso8601String(),
      'dailyCigarettes': dailyCigarettes,
      'cigarettePrice': cigarettePrice,
      'motivations': motivations,
      'personalReason': personalReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      quitDate: DateTime.parse(json['quitDate']),
      dailyCigarettes: json['dailyCigarettes'],
      cigarettePrice: json['cigarettePrice'].toDouble(),
      motivations: List<String>.from(json['motivations']),
      personalReason: json['personalReason'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  UserProfile copyWith({
    String? id,
    DateTime? quitDate,
    int? dailyCigarettes,
    double? cigarettePrice,
    List<String>? motivations,
    String? personalReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      quitDate: quitDate ?? this.quitDate,
      dailyCigarettes: dailyCigarettes ?? this.dailyCigarettes,
      cigarettePrice: cigarettePrice ?? this.cigarettePrice,
      motivations: motivations ?? this.motivations,
      personalReason: personalReason ?? this.personalReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Chat Message Model
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
            (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
    );
  }
}

enum MessageType { text, image, audio, tip }

// Self Note Model
enum MoodType { happy, neutral, challenging, anxious, confident, }

class SelfNote {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final MoodType mood;
  final List<String> tags;

  SelfNote({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'mood': mood.toString(),
      'tags': tags,
    };
  }

  factory SelfNote.fromJson(Map<String, dynamic> json) {
    return SelfNote(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      mood: MoodType.values.firstWhere(
            (e) => e.toString() == json['mood'],
        orElse: () => MoodType.neutral,
      ),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

// Emergency Tip Model
class EmergencyTip {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String colorHex;
  final int durationSeconds;
  final TipCategory category;
  final int priority;

  EmergencyTip({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.colorHex,
    required this.durationSeconds,
    required this.category,
    this.priority = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'colorHex': colorHex,
      'durationSeconds': durationSeconds,
      'category': category.toString(),
      'priority': priority,
    };
  }

  factory EmergencyTip.fromJson(Map<String, dynamic> json) {
    return EmergencyTip(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconName: json['iconName'],
      colorHex: json['colorHex'],
      durationSeconds: json['durationSeconds'],
      category: TipCategory.values.firstWhere(
            (e) => e.toString() == json['category'],
        orElse: () => TipCategory.general,
      ),
      priority: json['priority'] ?? 1,
    );
  }
}

enum TipCategory { breathing, physical, mental, social, general }

// Health Milestone Model
class HealthMilestone {
  final String id;
  final String title;
  final String description;
  final int minutesFromQuit;
  final String iconName;
  final String colorHex;
  final bool isAchieved;
  final DateTime? achievedDate;

  HealthMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.minutesFromQuit,
    required this.iconName,
    required this.colorHex,
    this.isAchieved = false,
    this.achievedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'minutesFromQuit': minutesFromQuit,
      'iconName': iconName,
      'colorHex': colorHex,
      'isAchieved': isAchieved,
      'achievedDate': achievedDate?.toIso8601String(),
    };
  }

  factory HealthMilestone.fromJson(Map<String, dynamic> json) {
    return HealthMilestone(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      minutesFromQuit: json['minutesFromQuit'],
      iconName: json['iconName'],
      colorHex: json['colorHex'],
      isAchieved: json['isAchieved'] ?? false,
      achievedDate: json['achievedDate'] != null
          ? DateTime.parse(json['achievedDate'])
          : null,
    );
  }

  HealthMilestone copyWith({
    String? id,
    String? title,
    String? description,
    int? minutesFromQuit,
    String? iconName,
    String? colorHex,
    bool? isAchieved,
    DateTime? achievedDate,
  }) {
    return HealthMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      minutesFromQuit: minutesFromQuit ?? this.minutesFromQuit,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      isAchieved: isAchieved ?? this.isAchieved,
      achievedDate: achievedDate ?? this.achievedDate,
    );
  }
}

// Progress Statistics Model
class ProgressStats {
  final DateTime quitDate;
  final int cigarettesAvoided;
  final double moneySaved;
  final int smokeFreeMinutes;
  final List<HealthMilestone> achievedMilestones;
  final double healthScore;

  ProgressStats({
    required this.quitDate,
    required this.cigarettesAvoided,
    required this.moneySaved,
    required this.smokeFreeMinutes,
    required this.achievedMilestones,
    required this.healthScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'quitDate': quitDate.toIso8601String(),
      'cigarettesAvoided': cigarettesAvoided,
      'moneySaved': moneySaved,
      'smokeFreeMinutes': smokeFreeMinutes,
      'achievedMilestones': achievedMilestones.map((m) => m.toJson()).toList(),
      'healthScore': healthScore,
    };
  }

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      quitDate: DateTime.parse(json['quitDate']),
      cigarettesAvoided: json['cigarettesAvoided'],
      moneySaved: json['moneySaved'].toDouble(),
      smokeFreeMinutes: json['smokeFreeMinutes'],
      achievedMilestones: (json['achievedMilestones'] as List)
          .map((m) => HealthMilestone.fromJson(m))
          .toList(),
      healthScore: json['healthScore'].toDouble(),
    );
  }

  // Helper getters
  int get smokeFreeHours => smokeFreeMinutes ~/ 60;
  int get smokeFreeDays => smokeFreeMinutes ~/ (60 * 24);
  int get smokeFreeWeeks => smokeFreeDays ~/ 7;
  int get smokeFreeMonths => smokeFreeDays ~/ 30;

  String get formattedTimeSmokeeFree {
    if (smokeFreeDays > 0) {
      final hours = smokeFreeHours % 24;
      final minutes = smokeFreeMinutes % 60;
      return '$smokeFreeDays days, $hours hours, $minutes minutes';
    } else if (smokeFreeHours > 0) {
      final minutes = smokeFreeMinutes % 60;
      return '$smokeFreeHours hours, $minutes minutes';
    } else {
      return '$smokeFreeMinutes minutes';
    }
  }
}

// App Settings Model
class AppSettings {
  final bool notificationsEnabled;
  final bool emergencyNotificationsEnabled;
  final String language;
  final String theme;
  final int dailyReminderHour;
  final List<String> emergencyContacts;

  AppSettings({
    this.notificationsEnabled = true,
    this.emergencyNotificationsEnabled = true,
    this.language = 'ar',
    this.theme = 'light',
    this.dailyReminderHour = 9,
    this.emergencyContacts = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emergencyNotificationsEnabled': emergencyNotificationsEnabled,
      'language': language,
      'theme': theme,
      'dailyReminderHour': dailyReminderHour,
      'emergencyContacts': emergencyContacts,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      emergencyNotificationsEnabled: json['emergencyNotificationsEnabled'] ?? true,
      language: json['language'] ?? 'ar',
      theme: json['theme'] ?? 'light',
      dailyReminderHour: json['dailyReminderHour'] ?? 9,
      emergencyContacts: List<String>.from(json['emergencyContacts'] ?? []),
    );
  }

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? emergencyNotificationsEnabled,
    String? language,
    String? theme,
    int? dailyReminderHour,
    List<String>? emergencyContacts,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emergencyNotificationsEnabled: emergencyNotificationsEnabled ?? this.emergencyNotificationsEnabled,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }
}