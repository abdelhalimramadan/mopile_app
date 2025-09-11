import 'package:flutter/material.dart';
import '../models/models.dart';

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({Key? key}) : super(key: key);

  @override
  _AddNoteDialogState createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  MoodType _selectedMood = MoodType.neutral;
  final List<Map<String, dynamic>> _moodOptions = [
    {
      'mood': MoodType.happy,
      'label': 'happy',
      'icon': Icons.sentiment_very_satisfied,
      'color': Colors.green
    },
    {
      'mood': MoodType.neutral,
      'label': 'neutral',
      'icon': Icons.sentiment_neutral,
      'color': Colors.blueGrey
    },
    {
      'mood': MoodType.challenging,
      'label': 'challenging',
      'icon': Icons.sentiment_dissatisfied,
      'color': Colors.orange
    },
    {
      'mood': MoodType.anxious,
      'label': 'anxious',
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Colors.red
    },
    {
      'mood': MoodType.confident,
      'label': 'confident',
      'icon': Icons.sentiment_satisfied_alt,
      'color': Colors.blue
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newNote = SelfNote(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        date: DateTime.now(),
        mood: _selectedMood, id: '',
      );
      Navigator.of(context).pop(newNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Note', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'How are you feeling today?',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your note';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Select your mood:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _moodOptions.map((mood) {
                    final isSelected = _selectedMood == mood['mood'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = mood['mood'] as MoodType),  // Changed from Mood to MoodType
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              mood['icon'],
                              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              mood['label'],
                              style: TextStyle(
                                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}