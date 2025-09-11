import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class AIService {
  static const String _apiKey = 'sk-2RWjtCVWyKIB2iLiIvyggQ';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  // System prompt for the AI assistant
  static const String _systemPrompt = '''
You are a helpful AI assistant specialized in helping people quit smoking. You provide:
- Supportive and encouraging responses in Arabic
- Practical tips for managing cravings
- Health information about smoking cessation benefits
- Motivational guidance during difficult moments
- Personalized advice based on user progress

Always respond in Arabic and keep responses concise but helpful. Be empathetic and understanding of the challenges of quitting smoking.
''';

  // Generate AI response
  static Future<String> generateResponse(
      String userMessage, {
        List<ChatMessage>? conversationHistory,
        UserProfile? userProfile,
      }) async {
    try {
      final messages = _buildMessageList(
        userMessage,
        conversationHistory: conversationHistory,
        userProfile: userProfile,
      );

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'max_tokens': 200,
          'temperature': 0.7,
          'frequency_penalty': 0.1,
          'presence_penalty': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        print('AI Service Error: ${response.statusCode} - ${response.body}');
        return _getDefaultResponse(userMessage);
      }
    } catch (e) {
      print('AI Service Exception: $e');
      return _getDefaultResponse(userMessage);
    }
  }

  // Generate emergency help response
  static Future<String> generateEmergencyResponse(
      String cravingIntensity, {
        UserProfile? userProfile,
        int? daysSinceQuit,
      }) async {
    try {
      final contextMessage = _buildEmergencyContext(
        cravingIntensity,
        userProfile: userProfile,
        daysSinceQuit: daysSinceQuit,
      );

      final messages = [
        {'role': 'system', 'content': _systemPrompt},
        {'role': 'user', 'content': contextMessage},
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'max_tokens': 150,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        return _getEmergencyDefaultResponse(cravingIntensity);
      }
    } catch (e) {
      print('Emergency AI Service Exception: $e');
      return _getEmergencyDefaultResponse(cravingIntensity);
    }
  }

  // Generate motivational message
  static Future<String> generateMotivationalMessage({
    UserProfile? userProfile,
    ProgressStats? stats,
    String? context,
  }) async {
    try {
      final contextMessage = _buildMotivationalContext(
        userProfile: userProfile,
        stats: stats,
        context: context,
      );

      final messages = [
        {'role': 'system', 'content': _systemPrompt},
        {'role': 'user', 'content': contextMessage},
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'max_tokens': 100,
          'temperature': 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        return _getRandomMotivationalMessage();
      }
    } catch (e) {
      print('Motivational AI Service Exception: $e');
      return _getRandomMotivationalMessage();
    }
  }

  // Generate personalized tip
  static Future<String> generatePersonalizedTip({
    UserProfile? userProfile,
    ProgressStats? stats,
    MoodType? currentMood,
  }) async {
    try {
      final contextMessage = _buildTipContext(
        userProfile: userProfile,
        stats: stats,
        currentMood: currentMood,
      );

      final messages = [
        {'role': 'system', 'content': _systemPrompt},
        {'role': 'user', 'content': contextMessage},
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'max_tokens': 120,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        return _getRandomTip();
      }
    } catch (e) {
      print('Tip AI Service Exception: $e');
      return _getRandomTip();
    }
  }

  // Helper methods
  static List<Map<String, String>> _buildMessageList(
      String userMessage, {
        List<ChatMessage>? conversationHistory,
        UserProfile? userProfile,
      }) {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
    ];

    // Add user context if available
    if (userProfile != null) {
      final contextMessage = _buildUserContext(userProfile);
      messages.add({'role': 'system', 'content': contextMessage});
    }

    // Add recent conversation history (last 6 messages)
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      final recentMessages = conversationHistory.length > 6
          ? conversationHistory.sublist(conversationHistory.length - 6)
          : conversationHistory;

      for (final msg in recentMessages) {
        messages.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        });
      }
    }

    // Add current user message
    messages.add({'role': 'user', 'content': userMessage});

    return messages;
  }

  static String _buildUserContext(UserProfile userProfile) {
    final daysSinceQuit = DateTime.now().difference(userProfile.quitDate).inDays;
    return '''
User context:
- Days since quitting: $daysSinceQuit
- Previous daily cigarettes: ${userProfile.dailyCigarettes}
- Main motivations: ${userProfile.motivations.join(', ')}
- Personal reason: ${userProfile.personalReason}

Use this context to provide personalized responses.
''';
  }

  static String _buildEmergencyContext(
      String cravingIntensity, {
        UserProfile? userProfile,
        int? daysSinceQuit,
      }) {
    var context = 'I\'m experiencing a craving to smoke. Intensity: $cravingIntensity. ';

    if (daysSinceQuit != null) {
      context += 'I\'ve been smoke-free for $daysSinceQuit days. ';
    }

    if (userProfile?.motivations.isNotEmpty == true) {
      context += 'My motivations for quitting are: ${userProfile!.motivations.join(', ')}. ';
    }

    context += 'Please provide immediate help and encouragement to get through this moment.';

    return context;
  }

  static String _buildMotivationalContext({
    UserProfile? userProfile,
    ProgressStats? stats,
    String? context,
  }) {
    var message = 'Generate a motivational message for someone quitting smoking. ';

    if (stats != null) {
      message += 'They have been smoke-free for ${stats.smokeFreeDays} days, ';
      message += 'avoided ${stats.cigarettesAvoided} cigarettes, ';
      message += 'and saved ${stats.moneySaved.toStringAsFixed(0)} EGP. ';
    }

    if (userProfile?.motivations.isNotEmpty == true) {
      message += 'Their motivations include: ${userProfile!.motivations.join(', ')}. ';
    }

    if (context != null) {
      message += 'Context: $context. ';
    }

    message += 'Make it personal and encouraging in Arabic.';

    return message;
  }

  static String _buildTipContext({
    UserProfile? userProfile,
    ProgressStats? stats,
    MoodType? currentMood,
  }) {
    var message = 'Provide a helpful tip for someone quitting smoking. ';

    if (stats != null && stats.smokeFreeDays < 7) {
      message += 'They are in the early stages (${stats.smokeFreeDays} days). ';
    } else if (stats != null && stats.smokeFreeDays < 30) {
      message += 'They are in the intermediate stage (${stats.smokeFreeDays} days). ';
    }

    if (currentMood != null) {
      message += 'Current mood: ${currentMood.toString().split('.').last}. ';
    }

    message += 'Provide a practical, actionable tip in Arabic.';

    return message;
  }

  // Default responses when AI service fails
  static String _getDefaultResponse(String userMessage) {
    final responses = [
      'أفهم ما تمر به. الإقلاع عن التدخين تحدٍ كبير لكنك تستطيع تجاوزه.',
      'أنت تقوم بخطوة رائعة لصحتك. استمر وستشعر بالتحسن قريباً.',
      'تذكر أن الرغبة في التدخين مؤقتة وستزول خلال دقائق قليلة.',
      'جسمك يتعافى كل يوم تمضيه بدون تدخين. أنت على الطريق الصحيح.',
      'فكر في الأموال التي توفرها والصحة التي تكسبها. أنت تستحق حياة أفضل.',
    ];

    return responses[DateTime.now().millisecond % responses.length];
  }

  static String _getEmergencyDefaultResponse(String intensity) {
    final responses = {
      'low': [
        'الرغبة خفيفة وستمر قريباً. خذ نفساً عميقاً واشرب الماء.',
        'هذه رغبة بسيطة. قم بنشاط يشغل يديك لدقائق قليلة.',
      ],
      'medium': [
        'أعلم أن الرغبة قوية الآن. تنفس بعمق وتذكر لماذا بدأت هذه الرحلة.',
        'الرغبة ستختفي خلال 3-5 دقائق. امش قليلاً أو اتصل بصديق.',
      ],
      'high': [
        'أنت تواجه لحظة صعبة لكنك أقوى منها. تنفس واشرب الماء واتصل بأحد إذا احتجت للدعم.',
        'هذه اللحظة ستمر. أنت قد وصلت إلى هنا بقوتك وستتجاوز هذا أيضاً.',
      ],
    };

    final responseList = responses[intensity] ?? responses['medium']!;
    return responseList[DateTime.now().millisecond % responseList.length];
  }

  static String _getRandomMotivationalMessage() {
    final messages = [
      'كل يوم بدون تدخين هو انتصار جديد لك.',
      'أنت أقوى من أي رغبة في التدخين.',
      'جسمك يشكرك على هذا القرار الصحي الرائع.',
      'تذكر أن الصعوبة مؤقتة لكن الفوائد دائمة.',
      'أنت تستحق حياة صحية وطويلة بدون تدخين.',
      'كل نفس تتنفسه الآن أنظف وأصحى من قبل.',
    ];

    return messages[DateTime.now().millisecond % messages.length];
  }

  static String _getRandomTip() {
    final tips = [
      'اشرب الكثير من الماء لمساعدة جسمك على التخلص من السموم.',
      'مارس الرياضة الخفيفة يومياً لتحسين مزاجك وصحتك.',
      'تجنب الأماكن والأوقات التي كنت تدخن فيها عادة.',
      'احتفظ بيديك مشغولتين بأنشطة مفيدة.',
      'تناول وجبات صحية ومنتظمة للحفاظ على طاقتك.',
      'احط نفسك بأشخاص داعمين لقرارك.',
    ];

    return tips[DateTime.now().millisecond % tips.length];
  }
}