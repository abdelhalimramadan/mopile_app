import 'package:flutter/material.dart';
import '../models/models.dart';

import '../services/storage_services.dart';
import '../utils/app_theme.dart';

class SelfNotesScreen extends StatefulWidget {
  @override
  _SelfNotesScreenState createState() => _SelfNotesScreenState();
}

class _SelfNotesScreenState extends State<SelfNotesScreen> {
  List<SelfNote> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  MoodType? _selectedMoodFilter;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);

    try {
      final notes = StorageService.getSelfNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notes: $e');
      setState(() => _isLoading = false);
    }
  }

  List<SelfNote> get _filteredNotes {
    var filtered = _notes.where((note) {
      final matchesSearch = _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesMood = _selectedMoodFilter == null || note.mood == _selectedMoodFilter;

      return matchesSearch && matchesMood;
    }).toList();

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Personal Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('Filter by Mood'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export Notes'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: Icon(Icons.add),
        tooltip: 'Add New Note',
      ),
    );
  }

  Widget _buildBody() {
    if (_notes.isEmpty) {
      return _buildEmptyState();
    }

    final filteredNotes = _filteredNotes;

    if (filteredNotes.isEmpty) {
      return _buildNoResultsState();
    }

    return Column(
      children: [
        if (_searchQuery.isNotEmpty || _selectedMoodFilter != null)
          _buildFilterChips(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadNotes,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                return _buildNoteCard(filteredNotes[index]);
              },
            ),
          ),
        ),
      ],
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
                Icons.note_alt,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No notes yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Start writing your personal notes about your quit smoking journey.\nRecord your feelings, experiences, and achievements.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddNoteDialog,
              icon: Icon(Icons.add),
              label: Text('Add First Note'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'No notes match your current search or filter criteria',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: _clearFilters,
              child: Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_searchQuery.isNotEmpty)
              Chip(
                label: Text('Search: "$_searchQuery"'),
                onDeleted: () => setState(() => _searchQuery = ''),
                deleteIcon: Icon(Icons.close, size: 16),
              ),
            if (_searchQuery.isNotEmpty && _selectedMoodFilter != null)
              SizedBox(width: 8),
            if (_selectedMoodFilter != null)
              Chip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppTheme.getMoodIcon(_selectedMoodFilter!),
                      size: 16,
                      color: AppTheme.getMoodColor(_selectedMoodFilter!),
                    ),
                    SizedBox(width: 4),
                    Text(_getMoodName(_selectedMoodFilter!)),
                  ],
                ),
                onDeleted: () => setState(() => _selectedMoodFilter = null),
                deleteIcon: Icon(Icons.close, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(SelfNote note) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showNoteDetails(note),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.getMoodColor(note.mood).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      AppTheme.getMoodIcon(note.mood),
                      color: AppTheme.getMoodColor(note.mood),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatDate(note.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (action) => _handleNoteAction(action, note),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.tags.isNotEmpty) ...[
                SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: note.tags.map((tag) => Chip(
                    label: Text(tag),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    labelStyle: TextStyle(fontSize: 11),
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditNoteDialog(),
      barrierDismissible: false,
    ).then((note) {
      if (note != null) {
        _addNote(note);
      }
    });
  }

  void _showEditNoteDialog(SelfNote note) {
    showDialog(
      context: context,
      builder: (context) => AddEditNoteDialog(note: note),
      barrierDismissible: false,
    ).then((updatedNote) {
      if (updatedNote != null) {
        _updateNote(note.id, updatedNote);
      }
    });
  }

  void _showNoteDetails(SelfNote note) {
    showDialog(
      context: context,
      builder: (context) => NoteDetailsDialog(note: note),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchText = _searchQuery;
        return AlertDialog(
          title: Text('Search Notes'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search in title or content...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => searchText = value,
            onSubmitted: (value) {
              setState(() => _searchQuery = value.trim());
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _searchQuery = searchText.trim());
                Navigator.pop(context);
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showMoodFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter by Mood'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.clear),
              title: Text('Show All'),
              onTap: () {
                setState(() => _selectedMoodFilter = null);
                Navigator.pop(context);
              },
            ),
            ...MoodType.values.map((mood) => ListTile(
              leading: Icon(
                AppTheme.getMoodIcon(mood),
                color: AppTheme.getMoodColor(mood),
              ),
              title: Text(_getMoodName(mood)),
              onTap: () {
                setState(() => _selectedMoodFilter = mood);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _addNote(SelfNote note) async {
    try {
      await StorageService.addSelfNote(note);
      await _loadNotes();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note saved successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving note'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _updateNote(String noteId, SelfNote updatedNote) async {
    try {
      await StorageService.updateSelfNote(noteId, updatedNote);
      await _loadNotes();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating note'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      await StorageService.deleteSelfNote(noteId);
      await _loadNotes();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note deleted'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting note'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedMoodFilter = null;
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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

  void _handleMenuAction(String action) {
    switch (action) {
      case 'filter':
        _showMoodFilterDialog();
        break;
      case 'export':
        _exportNotes();
        break;
    }
  }

  void _handleNoteAction(String action, SelfNote note) {
    switch (action) {
      case 'edit':
        _showEditNoteDialog(note);
        break;
      case 'delete':
        _showDeleteDialog(note);
        break;
    }
  }

  void _showDeleteDialog(SelfNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNote(note.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportNotes() {
    // Implementation for exporting notes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export feature coming soon'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}

// Add/Edit Note Dialog
class AddEditNoteDialog extends StatefulWidget {
  final SelfNote? note;

  const AddEditNoteDialog({Key? key, this.note}) : super(key: key);

  @override
  _AddEditNoteDialogState createState() => _AddEditNoteDialogState();
}

class _AddEditNoteDialogState extends State<AddEditNoteDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  MoodType _selectedMood = MoodType.neutral;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedMood = widget.note!.mood;
      _tags = List.from(widget.note!.tags);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Add New Note' : 'Edit Note'),
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
              maxLength: 50,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              maxLength: 500,
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
                              size: 20,
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
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      labelText: 'Add Tag',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _addTag,
                  ),
                ),
                IconButton(
                  onPressed: () => _addTag(_tagController.text),
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => setState(() => _tags.remove(tag)),
                  deleteIcon: Icon(Icons.close, size: 16),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveNote,
          child: Text('Save'),
        ),
      ],
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
    }
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in both title and content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final note = SelfNote(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      date: widget.note?.date ?? DateTime.now(),
      mood: _selectedMood,
      tags: _tags,
    );

    Navigator.pop(context, note);
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
    _tagController.dispose();
    super.dispose();
  }
}

// Note Details Dialog
class NoteDetailsDialog extends StatelessWidget {
  final SelfNote note;

  const NoteDetailsDialog({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getMoodColor(note.mood).withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    AppTheme.getMoodIcon(note.mood),
                    color: AppTheme.getMoodColor(note.mood),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(note.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      note.content,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (note.tags.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Text(
                        'Tags:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: note.tags.map((tag) => Chip(
                          label: Text(tag),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}