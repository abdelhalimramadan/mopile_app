import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/models.dart';

import '../services/ai_services.dart';

import '../services/storage_services.dart';
import '../utils/app_theme.dart';

class EmergencyScreen extends StatefulWidget {
  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _timerController;
  late Animation<double> _breathingAnimation;
  Timer? _cravingTimer;
  int _remainingSeconds = 300; // 5 minutes
  bool _isBreathingActive = false;
  int _currentTipIndex = 0;
  String _cravingIntensity = 'medium';
  String _aiResponse = '';
  bool _isLoadingAI = false;

  final List<EmergencyTip> _emergencyTips = [
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

  final List<String> _motivationalQuotes = [
    "You are stronger than your craving",
    "Every moment you resist is a victory",
    "Your body thanks you for this healthy decision",
    "The craving will pass in just a few minutes",
    "You deserve a better, healthier life",
    "Think about how much money you've saved so far",
    "Your family is proud of your strength and willpower",
    "Every day you get stronger",
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCravingTimer();
    _getAISupport();
  }

  void _initializeAnimations() {
    _breathingController = AnimationController(
      duration: Duration(seconds: 12), // 4 sec inhale, 4 hold, 4 exhale
      vsync: this,
    );

    _timerController = AnimationController(
      duration: Duration(seconds: 300),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
  }

  void _startCravingTimer() {
    _timerController.forward();
    _cravingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          _showSuccessDialog();
        }
      });
    });
  }

  void _startBreathingExercise() {
    setState(() {
      _isBreathingActive = true;
    });
    _breathingController.repeat();

    // Stop exercise after 1 minute
    Timer(Duration(minutes: 1), () {
      if (mounted) {
        _stopBreathingExercise();
      }
    });
  }

  void _stopBreathingExercise() {
    setState(() {
      _isBreathingActive = false;
    });
    _breathingController.stop();
    _breathingController.reset();
  }

  String _getBreathingInstruction() {
    if (!_isBreathingActive) return 'Tap to start breathing exercise';

    final progress = _breathingController.value;
    if (progress < 0.33) {
      return 'Inhale... breathe in deeply';
    } else if (progress < 0.66) {
      return 'Hold... keep holding';
    } else {
      return 'Exhale... breathe out slowly';
    }
  }

  Future<void> _getAISupport() async {
    setState(() => _isLoadingAI = true);

    try {
      final userProfile = StorageService.getUserProfile();
      final stats = StorageService.getProgressStats();

      final response = await AIService.generateEmergencyResponse(
        _cravingIntensity,
        userProfile: userProfile,
        daysSinceQuit: stats?.smokeFreeDays,
      );

      setState(() {
        _aiResponse = response;
        _isLoadingAI = false;
      });
    } catch (e) {
      setState(() {
        _aiResponse = _getDefaultEmergencyResponse();
        _isLoadingAI = false;
      });
    }
  }

  String _getDefaultEmergencyResponse() {
    final responses = [
      "I know the craving is strong right now. Take deep breaths and remember why you started this journey.",
      "This craving will disappear in 3-5 minutes. Walk around or call a friend for support.",
      "You're facing a difficult moment but you're stronger than it. Breathe, drink water, and call someone if you need support.",
    ];
    return responses[Random().nextInt(responses.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        title: Text('Emergency Support'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.phone),
            onPressed: _callSupport,
            tooltip: 'Call Support',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCravingTimer(),
            SizedBox(height: 30),
            _buildCravingIntensitySelector(),
            SizedBox(height: 30),
            _buildBreathingExercise(),
            SizedBox(height: 30),
            _buildAISupport(),
            SizedBox(height: 30),
            _buildQuickTips(),
            SizedBox(height: 30),
            _buildMotivationalMessage(),
            SizedBox(height: 30),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCravingTimer() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[400]!, Colors.red[600]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.timer, size: 50, color: Colors.white),
          SizedBox(height: 15),
          Text(
            'Craving will fade in',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: 1 - (_remainingSeconds / 300),
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            'Stay strong! You\'re stronger than this craving',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCravingIntensitySelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How intense is your craving?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildIntensityButton('Low', 'low', Colors.green),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildIntensityButton('Medium', 'medium', Colors.orange),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildIntensityButton('High', 'high', Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntensityButton(String label, String value, Color color) {
    final isSelected = _cravingIntensity == value;
    return ElevatedButton(
      onPressed: () {
        setState(() => _cravingIntensity = value);
        _getAISupport();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildBreathingExercise() {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Text(
            'Calming Breathing Exercise',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
            ),
          ),
          SizedBox(height: 20),

          // Animated breathing circle
          GestureDetector(
            onTap: _isBreathingActive ? _stopBreathingExercise : _startBreathingExercise,
            child: AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breathingAnimation.value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.secondaryColor.withOpacity(0.8),
                          AppTheme.secondaryColor.withOpacity(0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.air,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 20),
          Text(
            _getBreathingInstruction(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),

          ElevatedButton(
            onPressed: _isBreathingActive ? _stopBreathingExercise : _startBreathingExercise,
            child: Text(_isBreathingActive ? 'Stop Exercise' : 'Start Exercise'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isBreathingActive ? Colors.red : AppTheme.secondaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISupport() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withOpacity(0.1), AppTheme.primaryColor.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'AI Support Message',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          if (_isLoadingAI)
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Getting personalized support...'),
              ],
            )
          else
            Text(
              _aiResponse,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _getAISupport,
              icon: Icon(Icons.refresh, size: 16),
              label: Text('Get New Message'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTips() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              'Quick Tips to Beat Cravings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 120,
            child: PageView.builder(
              itemCount: _emergencyTips.length,
              onPageChanged: (index) {
                setState(() {
                  _currentTipIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final tip = _emergencyTips[index];
                final color = AppTheme.getColorFromHex(tip.colorHex);
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getIconFromName(tip.iconName), size: 30, color: color),
                      SizedBox(height: 8),
                      Text(
                        tip.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: Text(
                          tip.description,
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _emergencyTips.length,
                  (index) => Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentTipIndex ? AppTheme.primaryColor : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalMessage() {
    final randomQuote = _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[300]!, Colors.purple[600]!],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(Icons.format_quote, size: 30, color: Colors.white),
          SizedBox(height: 10),
          Text(
            randomQuote,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Refresh with new quote
              });
            },
            child: Text('New Message'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _callSupport,
                icon: Icon(Icons.phone),
                label: Text('Call Support'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openChatWithAI,
                icon: Icon(Icons.chat),
                label: Text('Chat with AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _distractYourself,
                icon: Icon(Icons.games),
                label: Text('Distraction Games'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _recordNote,
                icon: Icon(Icons.note_add),
                label: Text('Record Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          children: [
            Icon(Icons.celebration, size: 50, color: Colors.green),
            SizedBox(height: 10),
            Text('Congratulations! You Beat the Craving'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Well done! You resisted for a full 5 minutes and overcame your smoking craving.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'You\'re stronger than you think! Keep going on your journey.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Back to Home'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _recordVictoryNote();
            },
            child: Text('Record Victory'),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'air':
        return Icons.air;
      case 'local_drink':
        return Icons.local_drink;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'pan_tool':
        return Icons.pan_tool;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.help;
    }
  }

  void _callSupport() {
    // Implementation for calling support
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Support Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone, color: Colors.green),
              title: Text('Call Quitline'),
              subtitle: Text('Free smoking cessation support'),
              onTap: () {
                Navigator.pop(context);
                // Launch phone dialer
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: AppTheme.primaryColor),
              title: Text('Online Chat'),
              subtitle: Text('24/7 text support'),
              onTap: () {
                Navigator.pop(context);
                // Open online chat
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _openChatWithAI() {
    Navigator.pop(context); // Go back to main screen
    // Navigate to AI assistant tab would be handled by parent
  }

  void _distractYourself() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Distraction Activities'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.games, color: Colors.orange),
              title: Text('Quick Games'),
              subtitle: Text('Simple puzzle games'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackbar('Quick Games');
              },
            ),
            ListTile(
              leading: Icon(Icons.music_note, color: Colors.purple),
              title: Text('Relaxing Music'),
              subtitle: Text('Calm your mind'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackbar('Relaxing Music');
              },
            ),
            ListTile(
              leading: Icon(Icons.book, color: Colors.blue),
              title: Text('Reading'),
              subtitle: Text('Short articles'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackbar('Reading');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _recordNote() {
    showDialog(
      context: context,
      builder: (context) => _QuickNoteDialog(),
    ).then((note) {
      if (note != null) {
        StorageService.addSelfNote(note);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Emergency note saved successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    });
  }

  void _recordVictoryNote() {
    final victoryNote = SelfNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Victory Over Craving',
      content: 'I successfully resisted a smoking craving and stayed strong for 5 minutes! I feel proud and more confident in my journey.',
      date: DateTime.now(),
      mood: MoodType.confident,
      tags: ['victory', 'craving', 'success'],
    );

    StorageService.addSelfNote(victoryNote);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Victory note recorded!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showComingSoonSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  @override
  void dispose() {
    _cravingTimer?.cancel();
    _breathingController.dispose();
    _timerController.dispose();
    super.dispose();
  }
}

// Quick Note Dialog for Emergency Situations
class _QuickNoteDialog extends StatefulWidget {
  @override
  _QuickNoteDialogState createState() => _QuickNoteDialogState();
}

class _QuickNoteDialogState extends State<_QuickNoteDialog> {
  final _contentController = TextEditingController();
  MoodType _selectedMood = MoodType.challenging;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Quick Emergency Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'How are you feeling right now?',
                hintText: 'Describe your current state, thoughts, or what helped...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              autofocus: true,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Mood: '),
                Expanded(
                  child: DropdownButton<MoodType>(
                    value: _selectedMood,
                    onChanged: (mood) => setState(() => _selectedMood = mood!),
                    items: [MoodType.challenging, MoodType.anxious, MoodType.neutral, MoodType.confident].map((mood) {
                      return DropdownMenuItem(
                        value: mood,
                        child: Row(
                          children: [
                            Icon(
                              AppTheme.getMoodIcon(mood),
                              color: AppTheme.getMoodColor(mood),
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(_getMoodName(mood)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_contentController.text.trim().isNotEmpty) {
              final note = SelfNote(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Emergency Note - ${DateTime.now().day}/${DateTime.now().month}',
                content: _contentController.text.trim(),
                date: DateTime.now(),
                mood: _selectedMood,
                tags: ['emergency', 'craving'],
              );
              Navigator.pop(context, note);
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  String _getMoodName(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.challenging:
        return 'Challenging';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.confident:
        return 'Confident';
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}