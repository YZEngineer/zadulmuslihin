import 'package:sqflite/sqflite.dart';
import 'package:zadulmuslihin/data/database/database.dart';
import 'package:zadulmuslihin/data/models/my_library.dart';
import 'database_helper.dart';

/// DAO للتعامل مع جدول مكتبتي
class MyLibraryDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  /// إضافة عنصر جديد إلى المكتبة
  Future<int> insertMyLibrary(MyLibrary myLibrary) async {
    try {
      final db = await _databaseHelper.database;
      return await db.insert(
        AppDatabase.tableMyLibrary,
        myLibrary.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('خطأ في إضافة عنصر إلى المكتبة: $e');
      return -1;
    }
  }

  /// تحديث عنصر في المكتبة
  Future<int> updateMyLibrary(MyLibrary myLibrary) async {
    try {
      final db = await _databaseHelper.database;
      return await db.update(
        AppDatabase.tableMyLibrary,
        myLibrary.toJson(),
        where: 'id = ?',
        whereArgs: [myLibrary.id],
      );
    } catch (e) {
      print('خطأ في تحديث عنصر في المكتبة: $e');
      return -1;
    }
  }
  Future<List<String>> getUniqueTypes() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        groupBy: 'type',
        orderBy: 'type',
      );
      return maps.map((map) => map['type'] as String).toList();
    } catch (e) {
      print('خطأ في الحصول على الأنواع الفريدة: $e');
      return [];
    }
  }

  /// حذف عنصر من المكتبة
  Future<int> deleteMyLibrary(int id) async {
    try {
      final db = await _databaseHelper.database;
      return await db.delete(
        AppDatabase.tableMyLibrary,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('خطأ في حذف عنصر من المكتبة: $e');
      return -1;
    }
  }



  Future<List<MyLibrary>> getMyLibraryByCategory(String category) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'id DESC',
      );

      return List.generate(maps.length, (i) {
        return MyLibrary.fromJson(maps[i]);
      });
    } catch (e) {
      print('خطأ في الحصول على عناصر المكتبة حسب التصنيف: $e');
      return [];
    }
  }

  /// الحصول على جميع التصنيفات الفريدة
  Future<List<String>> getUniqueCategories() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        groupBy: 'type',
        orderBy: 'type',
      );

      return maps.map((map) => map['type'] as String).toList();
    } catch (e) {
      print('خطأ في الحصول على التصنيفات الفريدة: $e');
      return [];
    }
  }

  /// الحصول على جميع التبويبات الفريدة حسب التصنيف
  Future<List<String>> getUniqueTabNamesByCategory(String category) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        where: 'category = ?',
        whereArgs: [category],
        groupBy: 'tabName',
        orderBy: 'tabName',
      );

      return maps.map((map) => map['tabName'] as String).toList();
    } catch (e) {
      print('خطأ في الحصول على التبويبات الفريدة حسب التصنيف: $e');
      return ["الكل"];
    }
  }

  /// الحصول على جميع التبويبات الفريدة
  Future<List<String>> getUniqueTabNames() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        groupBy: 'tabName',
        orderBy: 'tabName',
      );

      return maps.map((map) => map['tabName'] as String).toList();
    } catch (e) {
      print('خطأ في الحصول على التبويبات الفريدة: $e');
      return ["الكل"];
    }
  }

  /// الحصول على عنصر واحد بواسطة المعرف
  Future<MyLibrary?> getMyLibraryById(int id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return MyLibrary.fromJson(maps.first);
    } catch (e) {
      print('خطأ في الحصول على عنصر من المكتبة: $e');
      return null;
    }
  }

  /// الحصول على جميع عناصر المكتبة
  Future<List<MyLibrary>> getAllMyLibrary() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        orderBy: 'id DESC',
      );

      return List.generate(maps.length, (i) {
        return MyLibrary.fromJson(maps[i]);
      });
    } catch (e) {
      print('خطأ في الحصول على عناصر المكتبة: $e');
      return [];
    }
  }

  /// الحصول على عناصر المكتبة حسب التبويب
  Future<List<MyLibrary>> getMyLibraryByTab(String tabName) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        where: 'tabName = ?',
        whereArgs: [tabName],
        orderBy: 'id DESC',
      );

      return List.generate(maps.length, (i) {
        return MyLibrary.fromJson(maps[i]);
      });
    } catch (e) {
      print('خطأ في الحصول على عناصر المكتبة حسب التبويب: $e');
      return [];
    }
  }

  /// البحث في عناصر المكتبة
  Future<List<MyLibrary>> searchMyLibrary(String query) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        where: 'title LIKE ? OR content LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'id DESC',
      );

      return List.generate(maps.length, (i) {
        return MyLibrary.fromJson(maps[i]);
      });
    } catch (e) {
      print('خطأ في البحث في عناصر المكتبة: $e');
      return [];
    }
  }

  /// الحصول على عدد عناصر المكتبة
  Future<int> getMyLibraryCount() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM ${AppDatabase.tableMyLibrary}');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('خطأ في الحصول على عدد عناصر المكتبة: $e');
      return 0;
    }
  }

  /// الحصول على عناصر المكتبة حسب النوع
  Future<List<MyLibrary>> getMyLibraryByType(String type) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'id DESC',
      );

      return List.generate(maps.length, (i) {
        return MyLibrary.fromJson(maps[i]);
      });
    } catch (e) {
      print('خطأ في الحصول على عناصر المكتبة حسب النوع: $e');
      return [];
    }
  }

  /// البحث في عناصر المكتبة حسب النوع
  Future<List<MyLibrary>> searchMyLibraryByType(
      String query, String type) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        where: '(title LIKE ? OR content LIKE ?) AND type = ?',
        whereArgs: ['%$query%', '%$query%', type],
        orderBy: 'id DESC',
      );

      return List.generate(maps.length, (i) {
        return MyLibrary.fromJson(maps[i]);
      });
    } catch (e) {
      print('خطأ في البحث في عناصر المكتبة حسب النوع: $e');
      return [];
    }
  }

  /// الحصول على جميع تصنيفات الدورات الفريدة (حقل type حيث category='مقررات')
  Future<List<String>> getUniqueCourseCategories() async {
    try {
      final allLibrary = await getAllMyLibrary();
      if (allLibrary.isEmpty) {
        print("library is empty");
      }
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        where: 'category = ?',
        whereArgs: ['مقررات'],
        groupBy: 'type',
        orderBy: 'type',
      );
      print("category is  مقررات $maps");
      // استبعاد القيم الفارغة
      return maps
          .map((map) => map['type'] as String?)
          .where((type) => type != null && type.isNotEmpty)
          .cast<String>()
          .toList();
    } catch (e) {
      print('خطأ في الحصول على تصنيفات الدورات الفريدة: $e');
      return [];
    }
  }

  /// الحصول على عناصر المكتبة حسب النوع والتصنيف
  Future<List<MyLibrary>> getMyLibraryByTypeAndCategory(
      String type, String category) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppDatabase.tableMyLibrary,
        where: 'type = ? AND category = ?',
        whereArgs: [type, category],
        orderBy: 'id DESC',
      );

      return List.generate(maps.length, (i) {
        return MyLibrary.fromJson(maps[i]);
      });
    } catch (e) {
      print('خطأ في الحصول على عناصر المكتبة حسب النوع والتصنيف: $e');
      return [];
    }
  }
}
