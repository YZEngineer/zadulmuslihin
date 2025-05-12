import 'package:flutter/material.dart';
import '../data/database/my_library_dao.dart';
import '../data/models/my_library.dart';
import 'lesson_detail.dart';
import '../widgets/app_drawer.dart';

class LessonsPage extends StatefulWidget {
  @override
  _LessonsPageState createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  bool _isLoading = true;
  final MyLibraryDao _myLibraryDao = MyLibraryDao();

  // تصنيفات الدورات (مثل "دورات علمية", "دورات فقهية"...)
  List<String> _categories = [];
  // جميع الدورات المتاحة
  Map<String, List<MyLibrary>> _coursesByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadCoursesFromLibrary();
  }

  Future<void> _loadCoursesFromLibrary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // قراءة تصنيفات الدورات الفريدة
      final allLessons = await _myLibraryDao.getMyLibraryByCategory('مقررات');
      // إذا لم توجد تصنيفات، حاول الحصول على كل الدورات
      if (allLessons.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      // قراءةعدد جميع الدورات
      print("allLessons is ${allLessons.length}");

      // استخدام النوع (type) كاسم للتصنيف، بدلاً من 'courses'
      final Map<String, List<MyLibrary>> coursesByType = {};

      // تجميع الدورات حسب النوع (type)
      for (var lesson in allLessons) {
        if (!coursesByType.containsKey(lesson.type)) {
          coursesByType[lesson.type] = [];
        }
        coursesByType[lesson.type]!.add(lesson);
      }

      // احصل على قائمة الأنواع الفريدة
      final types = coursesByType.keys.toList();
      print("types is ${types.length} and types is $types");

      setState(() {
        _categories = types;
        _coursesByCategory = coursesByType;
        _isLoading = false;
      });
    } catch (e) {
      print('خطأ في تحميل الدورات: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('الدروس التعليمية'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'بحث',
            onPressed: () {
              showSearch(
                context: context,
                delegate: LessonSearchDelegate(_getAllCourses()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: _loadCoursesFromLibrary,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _categories.isEmpty || _coursesByCategory.isEmpty
              ? _buildEmptyState()
              : _buildCategoriesGrid(),
    );
  }

  // الحصول على قائمة تضم جميع الدورات من كافة التصنيفات
  List<MyLibrary> _getAllCourses() {
    final List<MyLibrary> allCourses = [];
    _coursesByCategory.forEach((_, courses) => allCourses.addAll(courses));
    return allCourses;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'لا توجد دورات متاحة حالياً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'يمكنك إضافة دورات من قسم المكتبة',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final coursesInCategory = _coursesByCategory[category] ?? [];

        if (coursesInCategory.isEmpty) return SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    width: 4,
                    height: 24,
                    margin: EdgeInsets.only(right: 8),
                  ),
                  Text(
                    category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      _navigateToAllCategoryCourses(
                          category, coursesInCategory);
                    },
                    child: Row(
                      children: [
                        Text('عرض الكل'),
                        Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: coursesInCategory.length,
                itemBuilder: (context, idx) =>
                    _buildCourseCard(coursesInCategory[idx]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCourseCard(MyLibrary course) {
    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonDetailPage(course: course),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                color: _getCategoryColor(course.type),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(course.type),
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title ?? course.type,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      _truncateContent(course.content),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    if (course.source != null && course.source!.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              course.source!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لتقصير المحتوى للعرض
  String _truncateContent(String content) {
    if (content.length <= 100) {
      return content;
    }
    return "${content.substring(0, 100)}...";
  }

  // دالة للحصول على لون التصنيف
  Color _getCategoryColor(String type) {
    // يمكن إضافة المزيد من الألوان حسب التصنيفات
    switch (type) {
      case "العقيدة":
        return Colors.green[700]!;
      case "الفقه":
        return Colors.blue[700]!;
      case "التفسير":
        return Colors.orange[700]!;
      case "الحديث":
        return Colors.purple[700]!;
      case "السيرة":
        return Colors.red[700]!;
      default:
        return Colors.teal[700]!;
    }
  }

  // دالة للحصول على أيقونة التصنيف
  IconData _getCategoryIcon(String type) {
    // يمكن إضافة المزيد من الأيقونات حسب التصنيفات
    switch (type) {
      case "العقيدة":
        return Icons.wb_sunny_outlined;
      case "الفقه":
        return Icons.gavel;
      case "التفسير":
        return Icons.menu_book;
      case "الحديث":
        return Icons.forum;
      case "السيرة":
        return Icons.history_edu;
      default:
        return Icons.school;
    }
  }

  void _navigateToAllCategoryCourses(
      String category, List<MyLibrary> coursesInCategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryCoursesPage(
          title: category,
          courses: coursesInCategory,
        ),
      ),
    );
  }
}

class CategoryCoursesPage extends StatelessWidget {
  final String title;
  final List<MyLibrary> courses;

  CategoryCoursesPage({
    required this.title,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.2),
                child: Icon(Icons.school, color: Colors.green),
              ),
              title: Text(course.title ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    course.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        course.source ?? 'غير معروف',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Spacer(),
                      if (course.links != null) ...[
                        Text(
                          course.links!,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonDetailPage(course: course),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// مندوب البحث في الدورات
class LessonSearchDelegate extends SearchDelegate<MyLibrary?> {
  final List<MyLibrary> courses;

  LessonSearchDelegate(this.courses);

  @override
  String get searchFieldLabel => 'بحث في الدروس...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Text('اكتب للبحث في الدروس'),
      );
    }

    final results = courses.where((course) {
      final titleMatch =
          (course.title ?? '').toLowerCase().contains(query.toLowerCase());
      final contentMatch =
          course.content.toLowerCase().contains(query.toLowerCase());
      final typeMatch = course.type.toLowerCase().contains(query.toLowerCase());
      final sourceMatch =
          (course.source ?? '').toLowerCase().contains(query.toLowerCase());

      return titleMatch || contentMatch || typeMatch || sourceMatch;
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد نتائج مطابقة'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final course = results[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              close(context, course);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonDetailPage(course: course),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(course.type),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(course.type),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title ?? course.type,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          course.content,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                course.type,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // دالة للحصول على لون التصنيف
  Color _getCategoryColor(String type) {
    // يمكن إضافة المزيد من الألوان حسب التصنيفات
    switch (type) {
      case "العقيدة":
        return Colors.green[700]!;
      case "الفقه":
        return Colors.blue[700]!;
      case "التفسير":
        return Colors.orange[700]!;
      case "الحديث":
        return Colors.purple[700]!;
      case "السيرة":
        return Colors.red[700]!;
      default:
        return Colors.teal[700]!;
    }
  }

  // دالة للحصول على أيقونة التصنيف
  IconData _getCategoryIcon(String type) {
    // يمكن إضافة المزيد من الأيقونات حسب التصنيفات
    switch (type) {
      case "العقيدة":
        return Icons.wb_sunny_outlined;
      case "الفقه":
        return Icons.gavel;
      case "التفسير":
        return Icons.menu_book;
      case "الحديث":
        return Icons.forum;
      case "السيرة":
        return Icons.history_edu;
      default:
        return Icons.school;
    }
  }
}
