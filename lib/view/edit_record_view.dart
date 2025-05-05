import 'package:flutter/material.dart';
import 'package:zadulmuslihin/services/database_info_service.dart';

class EditRecordView extends StatefulWidget {
  final String tableName;
  final int recordId;
  final Map<String, String> columnTypes;

  EditRecordView({
    required this.tableName,
    required this.recordId,
    required this.columnTypes,
  });

  @override
  _EditRecordViewState createState() => _EditRecordViewState();
}

class _EditRecordViewState extends State<EditRecordView> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final DatabaseInfoService _databaseInfoService = DatabaseInfoService();
  bool _isLoading = true;
  bool _recordLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // تحميل السجل من قاعدة البيانات
      final record = await _databaseInfoService.getRecordById(
        widget.tableName,
        widget.recordId,
      );

      if (record != null) {
        // تعبئة البيانات في النموذج
        setState(() {
          _formData.clear();
          widget.columnTypes.forEach((key, value) {
            if (record.containsKey(key)) {
              _formData[key] = record[key];
            }
          });
          _recordLoaded = true;
          _isLoading = false;
        });
      } else {
        // إذا لم يتم العثور على السجل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم العثور على السجل')),
        );
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل السجل: $e')),
      );
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل سجل في: ${widget.tableName}'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : !_recordLoaded
              ? Center(child: Text('لم يتم العثور على السجل'))
              : Directionality(
                  textDirection: TextDirection.rtl,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...widget.columnTypes.entries
                                .where((entry) =>
                                    entry.key != 'id') // استبعاد عمود المعرف
                                .map((entry) {
                              return _buildFormField(entry.key, entry.value);
                            }).toList(),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _updateRecord,
                              child: Text('حفظ التعديلات'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildFormField(String columnName, String columnType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: columnName,
          border: OutlineInputBorder(),
          hintText: 'أدخل قيمة ${columnName}',
        ),
        initialValue: _formData[columnName]?.toString() ?? '',
        keyboardType: _getKeyboardType(columnType),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال قيمة';
          }
          return null;
        },
        onSaved: (value) {
          if (columnType.contains('INT')) {
            _formData[columnName] = int.tryParse(value ?? '0') ?? 0;
          } else if (columnType.contains('REAL')) {
            _formData[columnName] = double.tryParse(value ?? '0.0') ?? 0.0;
          } else {
            _formData[columnName] = value ?? '';
          }
        },
      ),
    );
  }

  TextInputType _getKeyboardType(String columnType) {
    if (columnType.contains('INT')) {
      return TextInputType.number;
    } else if (columnType.contains('REAL')) {
      return TextInputType.numberWithOptions(decimal: true);
    } else {
      return TextInputType.text;
    }
  }

  Future<void> _updateRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      _formKey.currentState!.save();

      try {
        // إضافة معرف السجل
        final Map<String, dynamic> dataToUpdate = {..._formData};

        // تحديث السجل
        final result = await _databaseInfoService.updateRecord(
          widget.tableName,
          dataToUpdate,
          widget.recordId,
        );

        setState(() {
          _isLoading = false;
        });

        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تعديل السجل بنجاح')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل تعديل السجل')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }
}
