import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/storage_services.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // User data
  DateTime? _quitDate;
  int _dailyCigarettes = 20;
  double _cigarettePrice = 0.5;
  String _personalReason = '';
  List<String> _selectedMotivations = [];

  final List<String> _availableMotivations = [
    'Improve overall health',
    'Save money',
    'Protect family from secondhand smoke',
    'Improve athletic performance',
    'Eliminate smoking odor',
    'Reduce risk of diseases',
    'Be a role model',
    'Improve teeth and skin appearance',
  ];

  final List<String> _pageTitles = [
    'Welcome',
    'Quit Date',
    'Your Habits',
    'Your Motivation',
    'Summary',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildQuitDatePage(),
                  _buildSmokingHabitsPage(),
                  _buildMotivationPage(),
                  _buildSummaryPage(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.smoke_free,
            size: 50,
            color: AppTheme.primaryColor,
          ),
          SizedBox(height: 10),
          Text(
            _pageTitles[_currentPage],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (index) => _buildProgressDot(index)),
          ),
          SizedBox(height: 8),
          Text(
            'Step ${_currentPage + 1} of 5',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDot(int index) {
    return Expanded(
      child: Container(
        height: 4,
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: index <= _currentPage
              ? AppTheme.primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smoke_free,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 40),
          Text(
            'Welcome to Your Quit Smoking Journey',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'Let\'s set up the app together to help you successfully achieve your goal',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          Container(
            padding: EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                _buildFeatureItem(Icons.smart_toy, 'Personal AI Assistant'),
                _buildFeatureItem(Icons.trending_up, 'Track Daily Progress'),
                _buildFeatureItem(Icons.lightbulb, 'Personalized Tips & Guidance'),
                _buildFeatureItem(Icons.support_agent, 'Support in Tough Moments'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuitDatePage() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 80, color: AppTheme.secondaryColor),
          SizedBox(height: 30),
          Text(
            'When did you start your quit journey?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'Select the date you decided to quit smoking',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),

          Container(
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                _buildDateOption(
                  'Today (I\'m starting today)',
                  DateTime.now(),
                  Icons.today,
                ),
                _buildDateOption(
                  'Yesterday',
                  DateTime.now().subtract(Duration(days: 1)),
                  Icons.history,
                ),
                _buildDateOption(
                  'Select a specific date',
                  null,
                  Icons.date_range,
                  isCustom: true,
                ),
              ],
            ),
          ),

          if (_quitDate != null && !_isToday(_quitDate!) && !_isYesterday(_quitDate!))
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.primaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Selected Date: ${DateFormat('MM/dd/yyyy').format(_quitDate!)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateOption(String title, DateTime? date, IconData icon, {bool isCustom = false}) {
    final isSelected = isCustom
        ? (_quitDate != null && !_isToday(_quitDate!) && !_isYesterday(_quitDate!))
        : (_quitDate != null && date != null && _isSameDay(_quitDate!, date));

    return InkWell(
      onTap: () {
        if (isCustom) {
          _selectCustomDate();
        } else {
          setState(() => _quitDate = date);
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSmokingHabitsPage() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 80, color: AppTheme.warningColor),
          SizedBox(height: 30),
          Text(
            'Tell us about your previous habits',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // عدد السجائر يومياً
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How many cigarettes did you smoke daily?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Slider(
                          value: _dailyCigarettes.toDouble(),
                          min: 1,
                          max: 60,
                          divisions: 59,
                          label: '$_dailyCigarettes',
                          onChanged: (value) => setState(() => _dailyCigarettes = value.round()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1', style: Theme.of(context).textTheme.bodySmall),
                            Text(
                              '$_dailyCigarettes per day',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('60', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // سعر السيجارة
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How much does one cigarette cost?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          initialValue: _cigarettePrice.toString(),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Price in EGP',
                            suffixText: 'EGP',
                            prefixIcon: Icon(Icons.monetization_on),
                          ),
                          onChanged: (value) {
                            final price = double.tryParse(value);
                            if (price != null && price > 0) {
                              setState(() => _cigarettePrice = price);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // حساب التوفير المتوقع
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.successColor.withOpacity(0.1),
                          AppTheme.successColor.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.savings, color: AppTheme.successColor),
                            SizedBox(width: 8),
                            Text(
                              'Estimated Savings:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSavingsItem(
                              'Daily',
                              '${(_dailyCigarettes * _cigarettePrice).toStringAsFixed(2)} EGP',
                            ),
                            _buildSavingsItem(
                              'Monthly',
                              '${(_dailyCigarettes * _cigarettePrice * 30).toStringAsFixed(2)} EGP',
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        _buildSavingsItem(
                          'Yearly',
                          '${(_dailyCigarettes * _cigarettePrice * 365).toStringAsFixed(2)} EGP',
                          isLarge: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsItem(String period, String amount, {bool isLarge = false}) {
    return Column(
      children: [
        Text(
          amount,
          style: TextStyle(
            fontSize: isLarge ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.successColor,
          ),
        ),
        Text(
          period,
          style: TextStyle(
            fontSize: isLarge ? 14 : 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationPage() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          Icon(Icons.favorite, size: 80, color: AppTheme.errorColor),
          SizedBox(height: 30),
          Text(
            'What motivates you to quit?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'Select the reasons that motivate you (you can choose multiple)',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...(_availableMotivations.map((motivation) => _buildMotivationItem(motivation))),

                  SizedBox(height: 20),

                  // إضافة سبب مخصص
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit, color: AppTheme.secondaryColor),
                            SizedBox(width: 8),
                            Text(
                              'Add a personal reason:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Example: I want to be a role model for my children',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          maxLines: 2,
                          onChanged: (value) => _personalReason = value,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationItem(String motivation) {
    final isSelected = _selectedMotivations.contains(motivation);

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedMotivations.remove(motivation);
            } else {
              _selectedMotivations.add(motivation);
            }
          });
        },
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  motivation,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimaryColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPage() {
    final daysSinceQuit = _quitDate != null
        ? DateTime.now().difference(_quitDate!).inDays
        : 0;
    final moneySaved = daysSinceQuit * _dailyCigarettes * _cigarettePrice;

    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          Icon(Icons.celebration, size: 80, color: Colors.amber),
          SizedBox(height: 30),
          Text(
            'Your Journey Summary',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // إحصائيات سريعة
                  if (_quitDate != null) ...[
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: AppTheme.primaryGradientDecoration,
                      child: Column(
                        children: [
                          Text(
                            'Your Achievements So Far',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildQuickStat(
                                '$daysSinceQuit',
                                'days',
                                Icons.calendar_today,
                              ),
                              _buildQuickStat(
                                '${(daysSinceQuit * _dailyCigarettes)}',
                                'cigarettes\navoided',
                                Icons.smoke_free,
                              ),
                              _buildQuickStat(
                                '${moneySaved.toStringAsFixed(0)}',
                                'EGP\nsaved',
                                Icons.monetization_on,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],

                  // الدوافع المختارة
                  if (_selectedMotivations.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: AppTheme.secondaryColor),
                              SizedBox(width: 8),
                              Text(
                                'Your Motivations:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          ..._selectedMotivations.map((motivation) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.check, color: AppTheme.primaryColor, size: 16),
                                SizedBox(width: 8),
                                Expanded(child: Text(motivation)),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],

                  // السبب الشخصي
                  if (_personalReason.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.favorite, color: Colors.purple),
                              SizedBox(width: 8),
                              Text(
                                'Your Personal Reason:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            '"$_personalReason"',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],

                  // رسالة تحفيزية
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                        SizedBox(height: 15),
                        Text(
                          'You\'re on the right track!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Every smoke-free day is a new victory. There will be challenges, but you are stronger than them.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton.icon(
              onPressed: _previousPage,
              icon: Icon(Icons.arrow_back),
              label: Text('Back'),
            )
          else
            SizedBox(width: 100),

          ElevatedButton.icon(
            onPressed: _currentPage == 4 ? _finishSetup : _nextPage,
            icon: Icon(_currentPage == 4 ? Icons.check : Icons.arrow_forward),
            label: Text(_currentPage == 4 ? 'Start Journey' : 'Next'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_validateCurrentPage()) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 1: // صفحة تاريخ الإقلاع
        if (_quitDate == null) {
          _showError('Please select a quit date');
          return false;
        }
        break;
      case 2: // صفحة العادات
        if (_dailyCigarettes <= 0 || _cigarettePrice <= 0) {
          _showError('Please enter valid information');
          return false;
        }
        break;
      case 3: // صفحة الدوافع
        if (_selectedMotivations.isEmpty && _personalReason.trim().isEmpty) {
          _showError('Please select at least one motivation or enter a personal reason');
          return false;
        }
        break;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  Future<void> _selectCustomDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: 'Select quit date',
      cancelText: 'Cancel',
      confirmText: 'Confirm',
    );

    if (picked != null) {
      setState(() => _quitDate = picked);
    }
  }

  Future<void> _finishSetup() async {
    if (!_validateCurrentPage()) return;

    try {
      // Create user profile
      final profile = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        quitDate: _quitDate!,
        dailyCigarettes: _dailyCigarettes,
        cigarettePrice: _cigarettePrice,
        motivations: _selectedMotivations,
        personalReason: _personalReason,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to storage
      await StorageService.saveUserProfile(profile);
      await StorageService.setNotFirstTime();

      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome! You\'ve started your journey to a healthier life'),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Setup error: $e');
      _showError('Error saving data. Please try again.');
    }
  }

  // Helper methods
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}