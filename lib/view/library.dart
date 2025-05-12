import 'package:flutter/material.dart';
import '../data/database/my_library_dao.dart';
import '../data/models/my_library.dart';
import '../widgets/app_drawer.dart';
import '../data/database/database_manager.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = false;
  final MyLibraryDao _myLibraryDao = MyLibraryDao();
  List<MyLibrary> _libraryItems = [];
  List<String> _tabNames = [];
  String? _selectedTabName;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _sourceController = TextEditingController();
  TextEditingController _linksController = TextEditingController();
  TextEditingController _tabNameController = TextEditingController();
  String _selectedItemType = 'مقالة';

  final List<String> _itemTypes = [
    'مقالة',
    'آية',
    'حديث',
    'دعاء',
    'قصة',
    'اقتباس',
    'كتاب',
    'courses',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _loadLibraryItems();
  }

  Future<void> _loadLibraryItems() async {
    setState(() {
      DatabaseManager.instance.populateInitialData(); // لتعبئة المكتبة بالبيانات الافتراضية
      _isLoading = true;
    });

    try {
      // قراءة العناصر من قاعدة البيانات مع استثناء نوع 'courses'
      final items = await _myLibraryDao.getAllMyLibrary();
      final filteredItems =
          items.where((item) => item.type != 'courses').toList();

      // استخراج أسماء التبويبات الفريدة
      final Set<String> tabNamesSet = {};
      for (var item in filteredItems) {
        if (item.tabName.isNotEmpty) {
          tabNamesSet.add(item.tabName);
        }
      }

      setState(() {
        _libraryItems = filteredItems;
        _tabNames = tabNamesSet.toList();
      });

      // إعداد وحدة التحكم في التبويبات
      _tabController?.dispose();
      _tabController = TabController(
        length: _tabNames.length + 1, // +1 للتبويب "جميع العناصر"
        vsync: this,
      );

      _selectedTabName = _tabNames.isNotEmpty ? _tabNames[0] : null;

      // في حالة عدم وجود عناصر، إضافة بعض العناصر الافتراضية
      if (_libraryItems.isEmpty) {
        DatabaseManager.instance.populateInitialData();
      }
    } catch (e) {
      print('خطأ في تحميل عناصر المكتبة: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<MyLibrary> _getItemsByTab(String? tabName) {
    if (tabName == null) return [];
    return _libraryItems.where((item) => item.tabName == tabName).toList();
  }

  Future<void> _addLibraryItem() async {
    if (_contentController.text.isEmpty || _tabNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال المحتوى واسم التبويب على الأقل')),
      );
      return;
    }

    try {
      final item = MyLibrary(
        title: _titleController.text.isEmpty ? null : _titleController.text,
        content: _contentController.text,
        source: _sourceController.text.isEmpty ? null : _sourceController.text,
        tabName: _tabNameController.text,
        links: _linksController.text.isEmpty ? null : _linksController.text,
        type: _selectedItemType,
      );

      await _myLibraryDao.insertMyLibrary(item);

      _titleController.clear();
      _contentController.clear();
      _sourceController.clear();
      _linksController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إضافة العنصر بنجاح')),
      );

      _loadLibraryItems();
    } catch (e) {
      print('خطأ في إضافة عنصر: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إضافة العنصر')),
      );
    }
  }

  Future<void> _deleteLibraryItem(int id) async {
    try {
      await _myLibraryDao.deleteMyLibrary(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف العنصر بنجاح')),
      );
      _loadLibraryItems();
    } catch (e) {
      print('خطأ في حذف العنصر: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء حذف العنصر')),
      );
    }
  }

  Future<void> _deleteTab(String tabName) async {
    // التحقق من وجود عناصر في هذا التبويب
    final itemsInTab = _getItemsByTab(tabName);
    if (itemsInTab.isNotEmpty) {
      // عرض مربع حوار للتأكيد
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('حذف التبويب'),
          content: Text(
              'هذا التبويب يحتوي على ${itemsInTab.length} عنصر. هل أنت متأكد من حذف التبويب وجميع عناصره؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // حذف جميع العناصر في التبويب
      try {
        for (var item in itemsInTab) {
          if (item.id != null) {
            await _myLibraryDao.deleteMyLibrary(item.id!);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف التبويب وعناصره بنجاح')),
        );
        _loadLibraryItems();
      } catch (e) {
        print('خطأ في حذف التبويب: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء حذف التبويب')),
        );
      }
    } else {
      // التبويب فارغ، نقوم بإزالته من القائمة فقط
      setState(() {
        _tabNames.remove(tabName);
        _tabController?.dispose();
        _tabController = TabController(
          length: _tabNames.length + 1,
          vsync: this,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف التبويب')),
      );
    }
  }

  void _showAddItemDialog() {
    _tabNameController.text = _selectedTabName ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة عنصر جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'العنوان (اختياري)',
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
              TextField(
                controller: _sourceController,
                decoration: InputDecoration(
                  labelText: 'المصدر (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _tabNameController,
                decoration: InputDecoration(
                  labelText: 'اسم التبويب',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _linksController,
                decoration: InputDecoration(
                  labelText: 'روابط (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'النوع',
                  border: OutlineInputBorder(),
                ),
                value: _selectedItemType,
                items: _itemTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedItemType = value!;
                  });
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
              _addLibraryItem();
              Navigator.pop(context);
            },
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showAddTabDialog() {
    final TextEditingController tabController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة تبويب جديد'),
        content: TextField(
          controller: tabController,
          decoration: InputDecoration(
            labelText: 'اسم التبويب',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (tabController.text.isNotEmpty) {
                setState(() {
                  if (!_tabNames.contains(tabController.text)) {
                    _tabNames.add(tabController.text);
                    _tabController?.dispose();
                    _tabController = TabController(
                      length: _tabNames.length + 1,
                      vsync: this,
                    );
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showTabOptionsMenu(String tabName, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('تعديل التبويب'),
            onTap: () {
              Navigator.pop(context);
              _showEditTabDialog(tabName);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('حذف التبويب', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteTab(tabName);
            },
          ),
        ],
      ),
    );
  }

  void _showEditTabDialog(String currentTabName) {
    final TextEditingController tabController =
        TextEditingController(text: currentTabName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل اسم التبويب'),
        content: TextField(
          controller: tabController,
          decoration: InputDecoration(
            labelText: 'اسم التبويب الجديد',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tabController.text.isNotEmpty &&
                  tabController.text != currentTabName) {
                try {
                  // تحديث اسم التبويب في جميع العناصر
                  final itemsInTab = _getItemsByTab(currentTabName);
                  for (var item in itemsInTab) {
                    if (item.id != null) {
                      final updatedItem = MyLibrary(
                        id: item.id,
                        title: item.title,
                        content: item.content,
                        source: item.source,
                        tabName: tabController.text,
                        links: item.links,
                        type: item.type,
                      );
                      await _myLibraryDao.updateMyLibrary(updatedItem);
                    }
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم تحديث اسم التبويب بنجاح')),
                  );
                  _loadLibraryItems();
                } catch (e) {
                  print('خطأ في تحديث اسم التبويب: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('حدث خطأ أثناء تحديث اسم التبويب')),
                  );
                }

                Navigator.pop(context);
              }
            },
            child: Text('حفظ'),
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
    _sourceController.dispose();
    _linksController.dispose();
    _tabNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('المكتبة الإسلامية'),
        bottom: _tabNames.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  Tab(text: 'الكل'),
                  ..._tabNames
                      .map((name) => Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(name),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: () =>
                                      _showTabOptionsMenu(name, context),
                                  child: Icon(Icons.more_vert, size: 16),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'إضافة عنصر جديد',
            onPressed: _showAddItemDialog,
          ),
          IconButton(
            icon: Icon(Icons.create_new_folder),
            tooltip: 'إضافة تبويب جديد',
            onPressed: _showAddTabDialog,
          ),
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'بحث',
            onPressed: () {
              showSearch(
                context: context,
                delegate: LibrarySearchDelegate(_libraryItems),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tabNames.isEmpty
              ? _buildEmptyView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllItemsTab(),
                    ..._tabNames.map((name) => _buildTabContent(name)).toList(),
                  ],
                ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('المكتبة فارغة'),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: DatabaseManager.instance.populateInitialData,
            child: Text('إضافة محتوى نموذجي'),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _showAddTabDialog,
            child: Text('إضافة تبويب جديد'),
          ),
        ],
      ),
    );
  }

  Widget _buildAllItemsTab() {
    if (_libraryItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد عناصر في المكتبة'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showAddItemDialog,
              child: Text('إضافة عنصر جديد'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _libraryItems.length,
      itemBuilder: (context, index) {
        final item = _libraryItems[index];
        return _buildLibraryItemCard(item);
      },
    );
  }

  Widget _buildTabContent(String tabName) {
    final itemsInTab = _getItemsByTab(tabName);

    if (itemsInTab.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد عناصر في هذا التبويب'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _selectedTabName = tabName;
                _tabNameController.text = tabName;
                _showAddItemDialog();
              },
              child: Text('إضافة عنصر جديد'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: itemsInTab.length,
      itemBuilder: (context, index) {
        final item = itemsInTab[index];
        return _buildLibraryItemCard(item);
      },
    );
  }

  Widget _buildLibraryItemCard(MyLibrary item) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.title != null)
                        Text(
                          item.title!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(height: item.title != null ? 8 : 0),
                      Text(item.content),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      if (item.id != null) {
                        _deleteLibraryItem(item.id!);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                if (item.source != null) ...[
                  Icon(Icons.person, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    item.source!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 16),
                ],
                Icon(Icons.folder, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  item.tabName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.type,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (item.links != null && item.links!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.link, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      item.links!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LibrarySearchDelegate extends SearchDelegate<String> {
  final List<MyLibrary> libraryItems;

  LibrarySearchDelegate(this.libraryItems);

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
        close(context, '');
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
        child: Text('ابدأ البحث في المكتبة'),
      );
    }

    final results = libraryItems.where((item) {
      final titleMatch =
          item.title?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final contentMatch =
          item.content.toLowerCase().contains(query.toLowerCase());
      final sourceMatch =
          item.source?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final tabMatch = item.tabName.toLowerCase().contains(query.toLowerCase());
      final typeMatch = item.type.toLowerCase().contains(query.toLowerCase());

      return titleMatch || contentMatch || sourceMatch || tabMatch || typeMatch;
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text('لا توجد نتائج لـ "$query"'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
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
                if (item.title != null)
                  Text(
                    item.title!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(height: item.title != null ? 8 : 0),
                Text(
                  item.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    if (item.source != null) ...[
                      Icon(Icons.person, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        item.source!,
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(width: 16),
                    ],
                    Icon(Icons.folder, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      item.tabName,
                      style: TextStyle(fontSize: 12),
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
}
