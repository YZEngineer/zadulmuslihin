import 'package:flutter/material.dart';
import 'package:zadulmuslihin/services/database_info_service.dart';
import 'package:zadulmuslihin/view/add_record_view.dart';
import 'package:zadulmuslihin/view/edit_record_view.dart';

class DatabaseTableView extends StatefulWidget {
  final String tableName;

  DatabaseTableView({required this.tableName});

  @override
  _DatabaseTableViewState createState() => _DatabaseTableViewState();
}

class _DatabaseTableViewState extends State<DatabaseTableView>
    with SingleTickerProviderStateMixin {
  final DatabaseInfoService _databaseInfoService = DatabaseInfoService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, dynamic>> _tableStructure = [];
  late TabController _tabController;
  bool _hasIdColumn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTableInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTableInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final structure =
          await _databaseInfoService.getTableStructure(widget.tableName);
      final data =
          await _databaseInfoService.getFullTableData(widget.tableName);

      // تحقق مما إذا كان الجدول يحتوي على عمود معرف
      _hasIdColumn = structure
          .any((column) => column['name'] == 'id' && column['pk'] == 1);

      setState(() {
        _tableStructure = structure;
        _tableData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('خطأ في تحميل معلومات الجدول: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRecord(int id) async {
    try {
      final result = await _databaseInfoService.deleteRecord(
        widget.tableName,
        'id = ?',
        [id],
      );

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف السجل بنجاح')),
        );
        // إعادة تحميل البيانات
        _loadTableInfo();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حذف السجل')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(int id) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد من رغبتك في حذف هذا السجل؟'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteRecord(id);
                },
                child: Text('حذف'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addNewRecord() async {
    // تحويل هيكل الجدول إلى قاموس من اسم العمود ونوعه
    final Map<String, String> columnTypes =
        await _databaseInfoService.getTableColumnTypes(widget.tableName);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecordView(
          tableName: widget.tableName,
          columnTypes: columnTypes,
        ),
      ),
    );

    if (result == true) {
      // إعادة تحميل بيانات الجدول
      _loadTableInfo();
    }
  }

  Future<void> _editRecord(int id) async {
    // تحويل هيكل الجدول إلى قاموس من اسم العمود ونوعه
    final Map<String, String> columnTypes =
        await _databaseInfoService.getTableColumnTypes(widget.tableName);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecordView(
          tableName: widget.tableName,
          recordId: id,
          columnTypes: columnTypes,
        ),
      ),
    );

    if (result == true) {
      // إعادة تحميل بيانات الجدول
      _loadTableInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جدول: ${widget.tableName}'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'البيانات'),
            Tab(text: 'الهيكل'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDataView(),
                _buildStructureView(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRecord,
        child: Icon(Icons.add),
        tooltip: 'إضافة سجل جديد',
      ),
    );
  }

  Widget _buildStructureView() {
    if (_tableStructure.isEmpty) {
      return Center(child: Text('لا يوجد هيكل للجدول'));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('الاسم')),
              DataColumn(label: Text('النوع')),
              DataColumn(label: Text('مفتاح أساسي')),
              DataColumn(label: Text('إلزامي')),
              DataColumn(label: Text('افتراضي')),
            ],
            rows: _tableStructure.map((column) {
              return DataRow(
                cells: [
                  DataCell(Text(column['name'] ?? '')),
                  DataCell(Text(column['type'] ?? '')),
                  DataCell(Text(column['pk'] == 1 ? 'نعم' : 'لا')),
                  DataCell(Text(column['notnull'] == 1 ? 'نعم' : 'لا')),
                  DataCell(Text(column['dflt_value']?.toString() ?? 'لا يوجد')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDataView() {
    if (_tableData.isEmpty) {
      return Center(child: Text('لا توجد بيانات في الجدول'));
    }

    // استخراج أسماء الأعمدة من أول سجل
    final columns = _tableData.first.keys.toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              columns: [
                // إضافة عمود للإجراءات إذا كان الجدول يحتوي على معرف
                if (_hasIdColumn) DataColumn(label: Text('الإجراءات')),
                ...columns.map((column) {
                  return DataColumn(
                    label: Text(
                      column.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ],
              rows: _tableData.map((rowData) {
                return DataRow(
                  cells: [
                    // إضافة خلية للإجراءات إذا كان الجدول يحتوي على معرف
                    if (_hasIdColumn)
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                if (rowData['id'] != null) {
                                  _editRecord(rowData['id']);
                                }
                              },
                              tooltip: 'تعديل',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                if (rowData['id'] != null) {
                                  _showDeleteConfirmation(rowData['id']);
                                }
                              },
                              tooltip: 'حذف',
                            ),
                          ],
                        ),
                      ),
                    ...columns.map((column) {
                      return DataCell(
                        Text(rowData[column]?.toString() ?? 'NULL'),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
