import 'package:flutter/material.dart';
import 'package:zadulmuslihin/services/database_info_service.dart';

class AddRecordView extends StatefulWidget {
  final String tableName;
  final Map<String, String> columnTypes;

  AddRecordView({
    required this.tableName,
    required this.columnTypes,
  });

  @override
  _AddRecordViewState createState() => _AddRecordViewState();
}

class _AddRecordViewState extends State<AddRecordView> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final DatabaseInfoService _databaseInfoService = DatabaseInfoService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تهيئة البيانات الافتراضية
    widget.columnTypes.forEach((key, value) {
      if (value.contains('INT')) {
        _formData[key] = 0;
      } else if (value.contains('REAL')) {
        _formData[key] = 0.0;
      } else {
        _formData[key] = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة سجل جديد: ${widget.tableName}'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...widget.columnTypes.entries.map((entry) {
                          return _buildFormField(entry.key, entry.value);
                        }).toList(),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveRecord,
                          child: Text('حفظ السجل'),
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
        initialValue: _formData[columnName].toString(),
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

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      _formKey.currentState!.save();

      try {
        final result = await _databaseInfoService.addRecord(
          widget.tableName,
          _formData,
        );

        setState(() {
          _isLoading = false;
        });

        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تمت إضافة السجل بنجاح')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشلت إضافة السجل')),
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
