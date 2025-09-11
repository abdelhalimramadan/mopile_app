import 'package:flutter/material.dart';
import '../models/models.dart';

import '../services/ai_services.dart';
import '../services/storage_services.dart';
import '../utils/app_theme.dart';

class AIAssistantScreen extends StatefulWidget {
  @override
  _AIAssistantScreenState createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  UserProfile? _userProfile;
  ProgressStats? _progressStats;

  final List<String> _quickSuggestions = [
    'I feel like smoking',
    'How to deal with stress?',
    'I need motivation',
    'What are the benefits of quitting?',
    'Tips to stay strong',
    'How to keep myself busy?',
  ];

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Load user data
    _userProfile = StorageService.getUserProfile();
    _progressStats = StorageService.getProgressStats();

    // Load existing messages
    final savedMessages = StorageService.getChatMessages();

    setState(() {
      _messages = savedMessages;
      _isInitialized = true;
    });

    // Add welcome message if no messages exist
    if (_messages.isEmpty) {
      await _addWelcomeMessage();
    }

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _addWelcomeMessage() async {
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _getWelcomeMessage(),
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(welcomeMessage);
    });

    await StorageService.addChatMessage(welcomeMessage);
  }

  String _getWelcomeMessage() {
    if (_userProfile != null && _progressStats != null) {
      return 'Hello! I\'m your AI assistant for quitting smoking. '
          'I see you\'ve made amazing progress - ${_progressStats!.smokeFreeDays} days smoke-free! '
          'How can I help you today?';
    }
    return 'Hello! I\'m your AI assistant for quitting smoking. How can I help you today?';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('AI Assistant'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.smart_toy, color: AppTheme.primaryColor),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Always here to help',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Clear Chat'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'emergency',
                child: Row(
                  children: [
                    Icon(Icons.emergency, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Emergency Help'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progressStats != null) _buildProgressBanner(),
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildMessagesList(),
          ),
          if (_messages.isEmpty || _shouldShowSuggestions()) _buildQuickSuggestions(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildProgressBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withOpacity(0.1), AppTheme.primaryColor.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: AppTheme.primaryColor),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_progressStats!.smokeFreeDays} days smoke-free • ${_progressStats!.cigarettesAvoided} cigarettes avoided',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Your AI Assistant is Here',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Ask me anything about quitting smoking.\nI\'m here to support and guide you on your journey.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildTypingIndicator();
        }
        return _buildMessage(_messages[index]);
      },
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryColor
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: message.isUser ? Radius.circular(18) : Radius.circular(4),
                  bottomRight: message.isUser ? Radius.circular(4) : Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : AppTheme.textPrimaryColor,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.secondaryColor,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryColor,
            child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: 4),
                _buildDot(1),
                SizedBox(width: 4),
                _buildDot(2),
                SizedBox(width: 8),
                Text(
                  'Typing...',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick suggestions:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickSuggestions.map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () => _sendMessage(suggestion),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(color: AppTheme.primaryColor),
                side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Type your message here...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                  ),
                  enabled: !_isLoading,
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _isLoading ? Colors.grey : AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isLoading ? null : () => _sendMessage(),
                icon: Icon(
                  _isLoading ? Icons.hourglass_empty : Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage([String? text]) async {
    final messageText = text ?? _messageController.text.trim();
    if (messageText.isEmpty || _isLoading) return;

    // Clear input
    _messageController.clear();
    _focusNode.unfocus();

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: messageText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    await StorageService.addChatMessage(userMessage);
    _scrollToBottom();

    try {
      // Get AI response
      final response = await AIService.generateResponse(
        messageText,
        conversationHistory: _messages.where((m) => !m.isUser).take(6).toList(),
        userProfile: _userProfile,
      );

      // Add AI response
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      await StorageService.addChatMessage(aiMessage);
      _scrollToBottom();

    } catch (e) {
      print('Error getting AI response: $e');

      // Add error message
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, there was a connection error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });

      await StorageService.addChatMessage(errorMessage);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _shouldShowSuggestions() {
    return _messages.length <= 2;
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear':
        _showClearDialog();
        break;
      case 'emergency':
        _requestEmergencyHelp();
        break;
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat'),
        content: Text('Do you want to delete all messages? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.clearChatMessages();
              setState(() {
                _messages.clear();
              });
              Navigator.pop(context);
              await _addWelcomeMessage();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _requestEmergencyHelp() async {
    final emergencyMessage = 'I need emergency help! I\'m having a strong urge to smoke right now.';
    await _sendMessage(emergencyMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}