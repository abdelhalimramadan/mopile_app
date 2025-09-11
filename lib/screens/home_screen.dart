import 'package:flutter/material.dart';
import 'dart:async';
import '../models/models.dart';
import '../services/ai_services.dart';
import '../services/notification_services.dart';
import '../services/storage_services.dart';
import '../utils/app_theme.dart';
import 'ai_assistant_screen.dart';
import 'self_notes_screen.dart';
import 'emergency_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  UserProfile? _userProfile;
  ProgressStats? _progressStats;
  Timer? _updateTimer;
  String _dailyTip = '';
  bool _isLoading = true;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _initializeScreens();
    _loadUserData();
    _startUpdateTimer();
    _loadDailyTip();
    _checkMilestones();
  }

  void _initializeScreens() {
    _screens.addAll([
      _buildDashboard(),
      AIAssistantScreen(),
      SelfNotesScreen(),
      ProgressScreen(),
    ]);
  }

  Future<void> _loadUserData() async {
    try {
      print('Loading user profile...');
      final profile = StorageService.getUserProfile();
      print('Profile loaded: ${profile != null}');

      print('Loading progress stats...');
      final stats = StorageService.getProgressStats();
      print('Stats loaded: ${stats != null}');

      setState(() {
        _userProfile = profile;
        _progressStats = stats;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error in _loadUserData:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data. Please restart the app.')),
        );
      }
    }
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (_userProfile != null) {
        final stats = StorageService.getProgressStats();
        setState(() {
          _progressStats = stats;
        });
      }
    });
  }

  Future<void> _loadDailyTip() async {
    try {
      final tip = await AIService.generatePersonalizedTip(
        userProfile: _userProfile,
        stats: _progressStats,
      );
      setState(() {
        _dailyTip = tip;
      });
    } catch (e) {
      setState(() {
        _dailyTip = 'Drink plenty of water to help your body get rid of nicotine faster';
      });
    }
  }

  Future<void> _checkMilestones() async {
    await NotificationService.checkAndNotifyMilestones();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading data...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'AI Assistant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt),
            label: 'My Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final daysQuit = _progressStats?.smokeFreeDays ?? 0;
    final moneySaved = (daysQuit * (_userProfile?.dailyCigarettes ?? 20) * 0.5).toStringAsFixed(2);

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Quit Smoking Journey', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF4CAF50),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header with progress
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You\'ve been smoke-free for',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    _buildTimeCounter(),
                    SizedBox(height: 16),
                    _buildStatsRow(),
                  ],
                ),
              ),

              // Quick Actions
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickActionButton(Icons.add_alert, 'Reminder', () {}),
                        _buildQuickActionButton(Icons.medication, 'Medication', () {}),
                        _buildQuickActionButton(Icons.people, 'Community', () {}),
                        _buildQuickActionButton(Icons.help, 'Help', () {}),
                      ],
                    ),
                  ],
                ),
              ),

              // Health Benefits
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Health Improvements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    _buildHealthBenefit('Blood Pressure', 'Back to normal levels', '✓', daysQuit >= 20),
                    _buildHealthBenefit('Oxygen', 'Improved oxygen flow', '✓', daysQuit >= 3),
                    _buildHealthBenefit('Lungs', 'Better lung function', '✓', daysQuit >= 30),
                    _buildHealthBenefit('Heart', 'Reduced heart disease risk', '✓', daysQuit >= 365),
                  ],
                ),
              ),

              // Daily Tip
              _buildDailyTipCard(),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF2E7D32)),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildHealthBenefit(String title, String description, String status, bool achieved) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: achieved ? Colors.green.shade100 : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Text(
              status,
              style: TextStyle(
                color: achieved ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: achieved ? Colors.black87 : Colors.grey,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: achieved ? Colors.black54 : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTipCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
              SizedBox(width: 8),
              Text('Daily Tip', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _dailyTip.isNotEmpty ? _dailyTip : 'Loading tip...',
            style: TextStyle(color: Colors.blueGrey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: AppTheme.primaryGradientDecoration,
      child: Column(
        children: [
          Icon(Icons.smoke_free, size: 50, color: Colors.white),
          SizedBox(height: 10),
          Text(
            'Welcome to Your Journey',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'You\'re taking a great step towards a healthier life',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCounter() {
    if (_progressStats == null) {
      return Container(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Text(
            'Smoke-Free For',
            style: AppTheme.cardSubtitleStyle,
          ),
          SizedBox(height: 10),
          Text(
            _progressStats!.formattedTimeSmokeeFree,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: _getProgressValue(),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    if (_progressStats == null) return SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Cigarettes Avoided',
            _progressStats!.cigarettesAvoided.toString(),
            Icons.smoke_free,
            AppTheme.successColor,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            'Money Saved',
            '${_progressStats!.moneySaved.toStringAsFixed(0)} EGP',
            Icons.monetization_on,
            AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTip() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppTheme.infoColor),
              SizedBox(width: 8),
              Text(
                'Tip of the Day',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.infoColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            _dailyTip,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _loadDailyTip,
              icon: Icon(Icons.refresh, size: 16),
              label: Text('New Tip'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.infoColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTheme.cardTitleStyle,
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Emergency Craving',
                Icons.emergency,
                Colors.red,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmergencyScreen()),
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _buildActionButton(
                'Add Note',
                Icons.note_add,
                AppTheme.secondaryColor,
                    () => _showAddNoteDialog(),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Celebrate',
                Icons.celebration,
                Colors.purple,
                    () => _showCelebrationDialog(),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: _buildActionButton(
                'Chat with Assistant',
                Icons.chat,
                AppTheme.primaryColor,
                    () => setState(() => _currentIndex = 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String title,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMilestones() {
    if (_progressStats == null || _progressStats!.achievedMilestones.isEmpty) {
      return SizedBox.shrink();
    }

    final recentMilestones = _progressStats!.achievedMilestones
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Achievements',
              style: AppTheme.cardTitleStyle,
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 3),
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 10),
        ...recentMilestones.map((milestone) => Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.successColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      milestone.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  double _getProgressValue() {
    if (_progressStats == null) return 0.0;

    // Progress based on days (30 days = 100%)
    final days = _progressStats!.smokeFreeDays;
    return (days / 30.0).clamp(0.0, 1.0);
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AddNoteDialog(),
    ).then((note) {
      if (note != null) {
        StorageService.addSelfNote(note);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note saved successfully')),
        );
      }
    });
  }

  void _showCelebrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber),
            SizedBox(width: 8),
            Text('Congratulations!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You\'re doing a great job on your quit smoking journey!'),
            SizedBox(height: 15),
            if (_progressStats != null) ...[
              Text('Your achievements:'),
              SizedBox(height: 10),
              Text('🚭 ${_progressStats!.cigarettesAvoided} cigarettes avoided'),
              Text('💰 ${_progressStats!.moneySaved.toStringAsFixed(0)} EGP saved'),
              Text('⏰ ${_progressStats!.formattedTimeSmokeeFree}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Thanks'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareProgress();
            },
            child: Text('Share Achievement'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                _showNotificationSettings();
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Reset Data'),
              onTap: () {
                Navigator.pop(context);
                _showResetDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    // Implementation for notification settings
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Data'),
        content: Text('Are you sure you want to delete all data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.clearAllData();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/setup');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Quit Smoking Assistant',
        applicationVersion: '1.0.0',
        applicationIcon: Icon(Icons.smoke_free, size: 50),
        children: [
          Text('A smart application to help you quit smoking in a healthy and thoughtful way.'),
        ],
      ),
    );
  }

  void _shareProgress() {
    // Implementation for sharing progress
    final message = 'I have been smoke-free for ${_progressStats?.smokeFreeDays ?? 0} days! 🎉';
    print('Sharing: $message');
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}

// Add Note Dialog Widget
class AddNoteDialog extends StatefulWidget {
  @override
  _AddNoteDialogState createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  MoodType _selectedMood = MoodType.neutral;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Mood: '),
                Expanded(
                  child: DropdownButton<MoodType>(
                    value: _selectedMood,
                    onChanged: (mood) => setState(() => _selectedMood = mood!),
                    items: MoodType.values.map((mood) {
                      return DropdownMenuItem(
                        value: mood,
                        child: Row(
                          children: [
                            Icon(
                              AppTheme.getMoodIcon(mood),
                              color: AppTheme.getMoodColor(mood),
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
            if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
              final note = SelfNote(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text,
                content: _contentController.text,
                date: DateTime.now(),
                mood: _selectedMood,
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
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}