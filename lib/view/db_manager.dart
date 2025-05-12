//DatabaseManager
import 'package:flutter/material.dart';
import '../data/database/database_helper.dart';
import '../data/database/database.dart';
import '../core/database/database_initializer.dart';

class DatabaseManager extends StatefulWidget {
  @override
  _DatabaseManagerState createState() => _DatabaseManagerState();
}

class _DatabaseManagerState extends State<DatabaseManager> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<String> _tables = [];
  String? _selectedTable;
  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, dynamic>> _tableStructure = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // التحقق من سلامة قاعدة البيانات
      await DatabaseInitializer.initializeDatabase();

      // جلب الجداول
      final db = await _databaseHelper.database;
      final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'");

      final tables = result.map((row) => row['name'] as String).toList();

      setState(() {
        _tables = tables;
        _isLoading = false;

        if (_tables.isEmpty) {
          _errorMessage = "لا توجد جداول في قاعدة البيانات";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "خطأ في تحميل قائمة الجداول: $e";
      });
      print("خطأ في تحميل قائمة الجداول: $e");
    }
  }

  Future<void> _loadTableData(String tableName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedTable = tableName;
    });

    try {
      // جلب هيكل الجدول (أسماء الأعمدة وأنواعها)
      final structure = await _databaseHelper.getTableStructure(tableName);

      // جلب بيانات الجدول
      final data = await _databaseHelper.getTableData(tableName, limit: 100);

      setState(() {
        _tableStructure = structure;
        _tableData = data;
        _isLoading = false;

        if (_tableData.isEmpty) {
          _errorMessage = "الجدول فارغ";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "خطأ في تحميل بيانات الجدول: $e";
      });
      print("خطأ في تحميل بيانات الجدول: $e");
    }
  }

  Future<void> _resetDatabase() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إعادة ضبط قاعدة البيانات'),
        content: Text(
            'هل أنت متأكد من أنك تريد إعادة ضبط قاعدة البيانات؟ سيتم حذف جميع البيانات.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });

              try {
                // استخدام الدالة العامة لإعادة ضبط قاعدة البيانات
                await DatabaseInitializer.resetDatabase();

                // إعادة تحميل الجداول
                _loadTables();

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('تم إعادة ضبط قاعدة البيانات بنجاح')));
              } catch (e) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = "خطأ في إعادة ضبط قاعدة البيانات: $e";
                });
                print("خطأ في إعادة ضبط قاعدة البيانات: $e");
              }
            },
            child: Text('إعادة الضبط'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecord(String tableName, int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف السجل'),
        content: Text('هل أنت متأكد من أنك تريد حذف هذا السجل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                await _databaseHelper.delete(tableName, 'id = ?', [id]);

                // إعادة تحميل بيانات الجدول
                _loadTableData(tableName);

                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم حذف السجل بنجاح')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في حذف السجل: $e')));
                print("خطأ في حذف السجل: $e");
              }
            },
            child: Text('حذف'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _showTableInfo(String tableName) async {
    try {
      final structure = await _databaseHelper.getTableStructure(tableName);
      final count = await _databaseHelper
          .rawQuery('SELECT COUNT(*) as count FROM $tableName');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('معلومات الجدول: $tableName'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('عدد السجلات: ${count.first['count']}'),
                SizedBox(height: 16),
                Text('هيكل الجدول:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ...structure.map((column) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('${column['name']} (${column['type']})'),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إغلاق'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في جلب معلومات الجدول: $e')));
      print("خطأ في جلب معلومات الجدول: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة قاعدة البيانات'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: _isLoading ? null : _loadTables,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            tooltip: 'إعادة ضبط قاعدة البيانات',
            onPressed: _isLoading ? null : _resetDatabase,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null && _tables.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(_errorMessage!),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTables,
                        child: Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    // قائمة الجداول
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border(
                            right: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: ListView.builder(
                        itemCount: _tables.length,
                        itemBuilder: (context, index) {
                          final tableName = _tables[index];
                          return ListTile(
                            title: Text(tableName),
                            selected: _selectedTable == tableName,
                            onTap: () => _loadTableData(tableName),
                            trailing: IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () => _showTableInfo(tableName),
                              tooltip: 'معلومات الجدول',
                            ),
                          );
                        },
                      ),
                    ),
                    // عرض بيانات الجدول
                    Expanded(
                      child: _selectedTable == null
                          ? Center(child: Text('اختر جدول لعرض بياناته'))
                          : _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : _errorMessage != null
                                  ? Center(child: Text(_errorMessage!))
                                  : Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            'جدول: $_selectedTable',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Expanded(
                                            child: _buildDataTable(),
                                          ),
                                        ],
                                      ),
                                    ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDataTable() {
    if (_tableData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('لا توجد بيانات'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddDialog(_selectedTable!),
              child: Text('إضافة سجل جديد'),
            ),
          ],
        ),
      );
    }

    // استخراج أسماء الأعمدة
    final columns =
        _tableStructure.map((col) => col['name'] as String).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('إضافة سجل جديد'),
              onPressed: () => _showAddDialog(_selectedTable!),
            ),
          ],
        ),
        SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('إجراءات')),
                  ...columns.map((col) => DataColumn(label: Text(col))),
                ],
                rows: _tableData.map((row) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              tooltip: 'حذف',
                              onPressed: () =>
                                  _deleteRecord(_selectedTable!, row['id']),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              tooltip: 'تعديل',
                              onPressed: () =>
                                  _showEditDialog(_selectedTable!, row),
                            ),
                          ],
                        ),
                      ),
                      ...columns.map((col) => DataCell(
                            Text(row[col]?.toString() ?? 'null'),
                          )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(String tableName, Map<String, dynamic> record) {
    // نسخة من السجل للتعديل
    final editedRecord = Map<String, dynamic>.from(record);

    // استبعاد عمود المعرف من التعديل
    final editableColumns = _tableStructure
        .where((col) => col['name'] != 'id')
        .map((col) => col['name'] as String)
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل سجل'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: editableColumns.map((columnName) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                    decoration: InputDecoration(labelText: columnName),
                    controller: TextEditingController(
                        text: editedRecord[columnName]?.toString() ?? ''),
                    onChanged: (value) {
                      editedRecord[columnName] = value;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  await _databaseHelper.update(
                      tableName, editedRecord, 'id = ?', [editedRecord['id']]);

                  // إعادة تحميل بيانات الجدول
                  _loadTableData(tableName);

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم تحديث السجل بنجاح')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ في تحديث السجل: $e')));
                  print("خطأ في تحديث السجل: $e");
                }
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(String tableName) {
    // إنشاء سجل جديد بقيم فارغة
    final newRecord = <String, dynamic>{};

    // استخراج أسماء الأعمدة القابلة للتحرير
    final editableColumns = _tableStructure
        .where((col) => col['name'] != 'id')
        .map((col) => col['name'] as String)
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة سجل جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: editableColumns.map((columnName) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                    decoration: InputDecoration(labelText: columnName),
                    onChanged: (value) {
                      newRecord[columnName] = value;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  // تعبئة الحقول الفارغة بقيم افتراضية
                  for (var column in editableColumns) {
                    newRecord[column] = newRecord[column] ?? '';
                  }

                  await _databaseHelper.insert(tableName, newRecord);

                  // إعادة تحميل بيانات الجدول
                  _loadTableData(tableName);

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم إضافة السجل بنجاح')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ في إضافة السجل: $e')));
                  print("خطأ في إضافة السجل: $e");
                }
              },
              child: Text('إضافة'),
            ),
          ],
        );
      },
    );
  }
}
