import 'package:flutter/material.dart';
import '../data/models/thought.dart';
import '../data/database/thought_dao.dart';
import '../data/database/thought_history_dao.dart';
import '../data/models/thought_history.dart';
import 'package:intl/intl.dart';

class ThoughtView extends StatefulWidget {
  @override
  _ThoughtViewState createState() => _ThoughtViewState();
}

class _ThoughtViewState extends State<ThoughtView>
    with SingleTickerProviderStateMixin {
  final ThoughtDao _thoughtDao = ThoughtDao();
  final ThoughtHistoryDao _thoughtHistoryDao = ThoughtHistoryDao();

  TabController? _tabController;
  List<Thought> _thoughts = [];
  List<ThoughtHistory> _history = [];

  bool _isLoading = true;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  int _selectedCategory = 1; // 0: دنيوي، 1: أخروي، 2: كلاهما

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadThoughts();
    _loadHistory();
  }

  Future<void> _loadThoughts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final thoughts = await _thoughtDao.getAll();
      setState(() {
        _thoughts = thoughts;
      });
    } catch (e) {
      print('خطأ في تحميل الأفكار: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _thoughtHistoryDao.getAll();
      setState(() {
        _history = history;
      });
    } catch (e) {
      print('خطأ في تحميل سجل الأفكار: $e');
    }
  }

  Future<void> _addThought() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال العنوان والمحتوى')),
      );
      return;
    }

    try {
      final thought = Thought(
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategory,
        date: DateTime.now(),
      );

      await _thoughtDao.insert(thought);

      _titleController.clear();
      _contentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إضافة الفكرة بنجاح')),
      );

      _loadThoughts();
    } catch (e) {
      print('خطأ في إضافة فكرة: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إضافة الفكرة')),
      );
    }
  }

  Future<void> _deleteThought(int id) async {
    try {
      await _thoughtDao.delete(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف الفكرة بنجاح')),
      );
      _loadThoughts();
    } catch (e) {
      print('خطأ في حذف الفكرة: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء حذف الفكرة')),
      );
    }
  }

  Future<void> _saveHistory() async {
    try {
      // حساب عدد الأفكار حسب الفئات
      int worldlyCount = 0; // دنيوي
      int spiritualCount = 0; // أخروي
      int bothCount = 0; // كلاهما

      for (var thought in _thoughts) {
        if (thought.category == 0)
          worldlyCount++;
        else if (thought.category == 1)
          spiritualCount++;
        else if (thought.category == 2) bothCount++;
      }

      int totalCount = _thoughts.isEmpty ? 1 : _thoughts.length;

      final thoughtHistory = ThoughtHistory(
        precentOf0: ((worldlyCount / totalCount) * 100).round(),
        precentOf1: ((spiritualCount / totalCount) * 100).round(),
        precentOf2: ((bothCount / totalCount) * 100).round(),
        totalday: totalCount,
      );

      await _thoughtHistoryDao.insert(thoughtHistory);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ سجل الأفكار بنجاح')),
      );

      _loadHistory();
    } catch (e) {
      print('خطأ في حفظ سجل الأفكار: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء حفظ سجل الأفكار')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الخواطر والأفكار'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'الخواطر'),
            Tab(text: 'الإحصائيات'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'إضافة فكرة جديدة',
            onPressed: () {
              _showAddThoughtDialog();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThoughtsTab(),
          _buildStatsTab(),
        ],
      ),
      floatingActionButton: _tabController?.index == 0
          ? FloatingActionButton(
              onPressed: _saveHistory,
              child: Icon(Icons.save),
              tooltip: 'حفظ إحصائيات اليوم',
            )
          : null,
    );
  }

  Widget _buildThoughtsTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_thoughts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد خواطر حتى الآن'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showAddThoughtDialog(),
              child: Text('إضافة خاطرة جديدة'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _thoughts.length,
      itemBuilder: (context, index) {
        final thought = _thoughts[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        thought.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildCategoryChip(thought.category),
                  ],
                ),
                SizedBox(height: 8),
                Text(thought.content),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd').format(thought.date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteThought(thought.id!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(int category) {
    String label;
    Color color;

    switch (category) {
      case 0:
        label = 'دنيوي';
        color = Colors.blue;
        break;
      case 1:
        label = 'أخروي';
        color = Colors.green;
        break;
      case 2:
        label = 'كلاهما';
        color = Colors.purple;
        break;
      default:
        label = 'غير محدد';
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildStatsTab() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد إحصائيات حتى الآن'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اليوم ${index + 1}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildProgressBar(
                    'الأفكار الدنيوية', item.precentOf0, Colors.blue),
                SizedBox(height: 8),
                _buildProgressBar(
                    'الأفكار الأخروية', item.precentOf1, Colors.green),
                SizedBox(height: 8),
                _buildProgressBar(
                    'الأفكار المشتركة', item.precentOf2, Colors.purple),
                SizedBox(height: 8),
                Text('إجمالي الخواطر: ${item.totalday}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(String label, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $percentage%'),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  void _showAddThoughtDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة خاطرة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'المحتوى',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'تصنيف الفكرة',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('دنيوي'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('أخروي'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('كلاهما'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              _addThought();
              Navigator.pop(context);
            },
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
