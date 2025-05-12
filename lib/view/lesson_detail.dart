import 'package:flutter/material.dart';
import '../data/models/my_library.dart';
import '../data/database/my_library_dao.dart';

class LessonDetailPage extends StatefulWidget {
  final MyLibrary course;

  LessonDetailPage({required this.course});

  @override
  _LessonDetailPageState createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MyLibraryDao _myLibraryDao = MyLibraryDao();
  List<String> _tabs = ['محتوى الدرس', 'الواجبات', 'الملفات', 'المراجع'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadDynamicTabs();
  }

  Future<void> _loadDynamicTabs() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // محاولة تحميل التبويبات المرتبطة بنوع الدرس
      List<MyLibrary> relatedItems = [];

      if (widget.course.category == 'مقررات') {
        // البحث عن دروس أخرى من نفس النوع (التصنيف)
        relatedItems =
            await _myLibraryDao.getMyLibraryByType(widget.course.type);
      } else if (widget.course.type.isNotEmpty) {
        // البحث عن دروس أخرى من نفس النوع
        relatedItems =
            await _myLibraryDao.getMyLibraryByType(widget.course.type);
      } else {
        // البحث حسب نوع التبويب إذا لم يكن هناك نوع محدد
        relatedItems =
            await _myLibraryDao.getMyLibraryByTab(widget.course.tabName);
      }

      // استخراج أسماء التبويبات الفريدة من العناصر ذات الصلة
      final Set<String> tabSet = {};
      for (var item in relatedItems) {
        if (item.tabName.isNotEmpty) {
          tabSet.add(item.tabName);
        }
      }

      // إنشاء قائمة التبويبات النهائية
      List<String> dynamicTabs = [];

      // أضف التبويبات الأساسية أولاً
      dynamicTabs.add('محتوى الدرس');

      // أضف التبويبات المستخرجة
      if (tabSet.isNotEmpty) {
        dynamicTabs.addAll(tabSet);
      }

      // أضف التبويبات الإضافية إذا لم تكن موجودة بالفعل
      if (!dynamicTabs.contains('المراجع')) dynamicTabs.add('المراجع');
      if (!dynamicTabs.contains('الملفات')) dynamicTabs.add('الملفات');
      if (!dynamicTabs.contains('الواجبات')) dynamicTabs.add('الواجبات');

      setState(() {
        _tabs = dynamicTabs;
        _isLoading = false;
        // إعادة تهيئة وحدة التحكم بالتبويبات
        _tabController.dispose();
        _tabController = TabController(length: _tabs.length, vsync: this);
      });
    } catch (e) {
      print('خطأ في تحميل التبويبات الديناميكية: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title ?? 'تفاصيل الدرس'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _buildTabContent(),
            ),
    );
  }

  List<Widget> _buildTabContent() {
    return _tabs.map((tab) {
      switch (tab) {
        case 'محتوى الدرس':
          return _buildLessonContentTab();
        case 'الواجبات':
          return _buildAssignmentsTab();
        case 'الملفات':
          return _buildFilesTab();
        case 'المراجع':
          return _buildReferencesTab();
        default:
          // تبويبات مخصصة أخرى
          return _buildCustomTabContent(tab);
      }
    }).toList();
  }

  Widget _buildCustomTabContent(String tabName) {
    return FutureBuilder<List<MyLibrary>>(
      future: _myLibraryDao.getMyLibraryByTab(tabName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('لا يوجد محتوى في هذا القسم'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonDetailPage(course: item),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getLessonColor(item.type),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            _getLessonIcon(item.type),
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title ?? 'بدون عنوان',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              item.content,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.source != null && item.source!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  item.source!,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLessonContentTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة لصورة ومعلومات الدرس
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(),
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course.title ?? 'تفاصيل الدرس',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.course.type,
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          if (widget.course.category != null &&
                              widget.course.category!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.course.category!,
                                style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
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
          SizedBox(height: 16),
          // بطاقة لمعلومات المدرس
          if (widget.course.source != null && widget.course.source!.isNotEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المدرس',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Icon(Icons.person, color: Colors.green),
                      ),
                      title: Text(widget.course.source!),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 16),
          // بطاقة لوصف الدرس
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وصف الدرس',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(),
                  Text(
                    widget.course.content,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // بطاقة معلومات إضافية
          SizedBox(height: 16),
          if (widget.course.links != null && widget.course.links!.isNotEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'روابط مفيدة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    ...widget.course.links!.split(',').map((link) {
                      final trimmedLink = link.trim();
                      return ListTile(
                        leading: Icon(Icons.link, color: Colors.blue),
                        title: Text(trimmedLink),
                        onTap: () {
                          // يمكن إضافة كود لفتح الرابط هنا
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('فتح الرابط: $trimmedLink')),
                          );
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // دالة للحصول على لون التصنيف
  Color _getCategoryColor() {
    // يمكن إضافة المزيد من الألوان حسب التصنيفات
    switch (widget.course.type) {
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
  IconData _getCategoryIcon() {
    // يمكن إضافة المزيد من الأيقونات حسب التصنيفات
    switch (widget.course.type) {
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

  Widget _buildAssignmentsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('لا توجد واجبات حالياً'),
        ],
      ),
    );
  }

  Widget _buildFilesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('لا توجد ملفات حالياً'),
        ],
      ),
    );
  }

  Widget _buildReferencesTab() {
    final links = widget.course.links?.split(',') ?? [];

    if (links.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد مراجع حالياً'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: links.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Icon(Icons.link),
            title: Text(links[index].trim()),
            onTap: () {
              // يمكن إضافة فتح الرابط هنا
            },
          ),
        );
      },
    );
  }

  // دالة للحصول على لون حسب نوع الدرس
  Color _getLessonColor(String type) {
    return _getCategoryColor(); // إعادة استخدام نفس الألوان
  }

  // دالة للحصول على أيقونة حسب نوع الدرس
  IconData _getLessonIcon(String type) {
    return _getCategoryIcon(); // إعادة استخدام نفس الأيقونات
  }
}
