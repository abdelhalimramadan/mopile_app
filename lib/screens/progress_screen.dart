import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_services.dart';


class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProgressStats? _progressStats;
  UserProfile? _userProfile;
  List<HealthMilestone> _milestones = [];
  bool _isLoading = true;

  num minutesFromQuit=0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);

    try {
      final stats = StorageService.getProgressStats();
      final profile = StorageService.getUserProfile();
      final milestones = StorageService.getHealthMilestones();

      setState(() {
        _progressStats = stats;
        _userProfile = profile;
        _milestones = milestones;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading progress data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Progress'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
              Tab(text: 'Achievements', icon: Icon(Icons.emoji_events)),
              Tab(text: 'Health Benefits', icon: Icon(Icons.favorite)),
            ],
          ),
        ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAchievementsTab(),
          _buildHealthBenefitsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_progressStats == null) {
      return Center(child: Text('No progress data available'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard(),
          SizedBox(height: 20),
          _buildMilestoneProgress(),
          SizedBox(height: 20),
          _buildHealthBenefitsPreview(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '${_progressStats!.smokeFreeDays}',
                  'Days Clean',
                  Icons.calendar_today,
                ),
                _buildStatItem(
                  '${_progressStats!.cigarettesAvoided}',
                  'Cigarettes Not Smoked',
                  Icons.smoke_free,
                ),
                _buildStatItem(
                  '\$${_progressStats!.moneySaved.toStringAsFixed(2)}',
                  'Money Saved',
                  Icons.attach_money,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMilestoneProgress() {
    final nextMilestone = _getNextMilestone();
    if (nextMilestone == null) return SizedBox();

    final progress = (_progressStats!.smokeFreeDays * 24 * 60) / nextMilestone.minutesFromQuit;    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Milestone',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  label: Text('${(nextMilestone.minutesFromQuit / (24 * 60)).round()} days'),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                )
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress > 1 ? 1.0 : progress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            SizedBox(height: 8),
            Text(
              progress >= 1
                  ? 'Milestone Reached!'
                  : '${(progress * 100).toStringAsFixed(1)}% complete',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (progress < 1) ...[
              SizedBox(height: 8),
              Text(
                '${((nextMilestone.minutesFromQuit - minutesFromQuit) / (24 * 60)).ceil()} days to go',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  HealthMilestone? _getNextMilestone() {
    if (_progressStats == null || _milestones.isEmpty) return null;

    final minutesFromQuit = _progressStats!.smokeFreeDays * 24 * 60;

    for (var milestone in _milestones) {
      if (minutesFromQuit < milestone.minutesFromQuit) {
        return milestone;
      }
    }
    return _milestones.last;
  }
  Widget _buildHealthBenefitsPreview() {
    final benefits = _getCurrentBenefits();
    if (benefits.isEmpty) return SizedBox();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Benefits',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            ...benefits.map((benefit) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text(benefit)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  List<String> _getCurrentBenefits() {
    if (_progressStats == null) return [];
    final days = _progressStats!.smokeFreeDays;
    final benefits = <String>[];

    if (days >= 1) benefits.add('Your blood pressure and heart rate have normalized');
    if (days >= 2) benefits.add('Nicotine has left your body');
    if (days >= 3) benefits.add('Your sense of taste and smell are improving');
    if (days >= 14) benefits.add('Your circulation and lung function are improving');
    if (days >= 30) benefits.add('Your lung capacity has increased');

    return benefits;
  }

  Widget _buildAchievementsTab() {
    if (_milestones.isEmpty) {
      return Center(child: Text('No achievements available'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _milestones.length,
      itemBuilder: (context, index) {
        final milestone = _milestones[index];
        final isUnlocked = _progressStats != null &&
            (_progressStats!.smokeFreeDays * 24 * 60) >= milestone.minutesFromQuit;
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          color: isUnlocked ? null : Colors.grey[100],
          child: ListTile(
            leading: Icon(
              isUnlocked ? Icons.verified : Icons.lock_outline,
              color: isUnlocked ? Colors.green : Colors.grey,
            ),
            title: Text(
              milestone.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
            subtitle: Text(
              milestone.description,
              style: TextStyle(
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
              trailing: Text(
                '${(milestone.minutesFromQuit / (24 * 60)).round()} days',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Theme.of(context).primaryColor : Colors.grey,
                ),
              )
          ),
        );
      },
    );
  }

  Widget _buildHealthBenefitsTab() {
    final benefits = [
      _buildBenefitItem(
        '20 minutes',
        'Heart rate and blood pressure drop to normal levels',
        Icons.favorite,
      ),
      _buildBenefitItem(
        '12 hours',
        'Carbon monoxide level in blood drops to normal',
        Icons.air,
      ),
      _buildBenefitItem(
        '2 weeks - 3 months',
        'Circulation improves and lung function increases',
        Icons.airline_seat_recline_normal,
      ),
      _buildBenefitItem(
        '1-9 months',
        'Coughing and shortness of breath decrease',
        Icons.health_and_safety,
      ),
      _buildBenefitItem(
        '1 year',
        'Risk of coronary heart disease is half that of a smoker\'s',
        Icons.favorite_border,
      ),
      _buildBenefitItem(
        '5 years',
        'Stroke risk is reduced to that of a non-smoker',
        Icons.bloodtype,
      ),
      _buildBenefitItem(
        '10 years',
        'Lung cancer death rate is about half that of a smoker\'s',
        Icons.health_and_safety,
      ),
    ];

    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: benefits.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) => benefits[index],
    );
  }

  Widget _buildBenefitItem(String time, String description, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}