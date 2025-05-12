import 'package:flutter/material.dart';

class QuranPage extends StatefulWidget {
  @override
  _QuranPageState createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<String> _surahs = [
    'الفاتحة',
    'البقرة',
    'آل عمران',
    'النساء',
    'المائدة',
    'الأنعام',
    'الأعراف',
    'الأنفال',
    'التوبة',
    'يونس',
    'هود',
    'يوسف',
    'الرعد',
    'إبراهيم',
    'الحجر',
    'النحل',
    'الإسراء',
    'الكهف',
    'مريم',
    'طه',
    'الأنبياء',
    'الحج',
    'المؤمنون',
    'النور',
    'الفرقان',
    'الشعراء',
    'النمل',
    'القصص',
    'العنكبوت',
    'الروم',
    'لقمان',
    'السجدة',
    'الأحزاب',
    'سبأ',
    'فاطر',
    'يس',
    'الصافات',
    'ص',
    'الزمر',
    'غافر',
    'فصلت',
    'الشورى',
    'الزخرف',
    'الدخان',
    'الجاثية',
    'الأحقاف',
    'محمد',
    'الفتح',
    'الحجرات',
    'ق',
    'الذاريات',
    'الطور',
    'النجم',
    'القمر',
    'الرحمن',
    'الواقعة',
    'الحديد',
    'المجادلة',
    'الحشر',
    'الممتحنة',
    'الصف',
    'الجمعة',
    'المنافقون',
    'التغابن',
    'الطلاق',
    'التحريم',
    'الملك',
    'القلم',
    'الحاقة',
    'المعارج',
    'نوح',
    'الجن',
    'المزمل',
    'المدثر',
    'القيامة',
    'الإنسان',
    'المرسلات',
    'النبأ',
    'النازعات',
    'عبس',
    'التكوير',
    'الانفطار',
    'المطففين',
    'الانشقاق',
    'البروج',
    'الطارق',
    'الأعلى',
    'الغاشية',
    'الفجر',
    'البلد',
    'الشمس',
    'الليل',
    'الضحى',
    'الشرح',
    'التين',
    'العلق',
    'القدر',
    'البينة',
    'الزلزلة',
    'العاديات',
    'القارعة',
    'التكاثر',
    'العصر',
    'الهمزة',
    'الفيل',
    'قريش',
    'الماعون',
    'الكوثر',
    'الكافرون',
    'النصر',
    'المسد',
    'الإخلاص',
    'الفلق',
    'الناس'
  ];

  List<int> _juzs = List.generate(30, (index) => index + 1);
  List<String> _bookmarks = [];
  List<String> _quranText = [];
  int _currentSurahIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSampleQuranText();
  }

  void _loadSampleQuranText() {
    // هنا يمكنك تحميل نص القرآن من قاعدة البيانات أو من ملف
    // هذا مجرد نص عينة للعرض
    _quranText = [
      "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
      "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
      "الرَّحْمَنِ الرَّحِيمِ",
      "مَالِكِ يَوْمِ الدِّينِ",
      "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
      "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ",
      "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
    ];
  }

  void _loadSurah(int index) {
    setState(() {
      _isLoading = true;
      _currentSurahIndex = index;
    });

    // في التطبيق الحقيقي، هنا يتم تحميل السورة من مصدر البيانات
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _addBookmark() {
    if (!_bookmarks.contains(_surahs[_currentSurahIndex])) {
      setState(() {
        _bookmarks.add(_surahs[_currentSurahIndex]);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('تمت إضافة ${_surahs[_currentSurahIndex]} إلى المفضلة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('القرآن الكريم'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'السور'),
            Tab(text: 'الأجزاء'),
            Tab(text: 'المفضلة'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: QuranSearchDelegate(_surahs),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // قائمة السور
          _buildSurahsList(),

          // قائمة الأجزاء
          _buildJuzsList(),

          // المفضلة
          _buildBookmarksList(),
        ],
      ),
    );
  }

  Widget _buildSurahsList() {
    return ListView.builder(
      itemCount: _surahs.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: Text((index + 1).toString()),
          ),
          title: Text(_surahs[index]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranReader(
                  title: _surahs[index],
                  index: index + 1,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJuzsList() {
    return ListView.builder(
      itemCount: _juzs.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: Text(_juzs[index].toString()),
          ),
          title: Text('الجزء ${_juzs[index]}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranReader(
                  title: 'الجزء ${_juzs[index]}',
                  index: _juzs[index],
                  isJuz: true,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookmarksList() {
    if (_bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد إشارات مرجعية'),
            SizedBox(height: 8),
            Text(
              'اضغط على أيقونة المفضلة عند قراءة السورة لإضافتها هنا',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        final surahName = _bookmarks[index];
        final surahIndex = _surahs.indexOf(surahName);

        return ListTile(
          leading: CircleAvatar(
            child: Text((surahIndex + 1).toString()),
          ),
          title: Text(surahName),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _bookmarks.removeAt(index);
              });
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranReader(
                  title: surahName,
                  index: surahIndex + 1,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}

class QuranReader extends StatefulWidget {
  final String title;
  final int index;
  final bool isJuz;

  QuranReader({
    required this.title,
    required this.index,
    this.isJuz = false,
  });

  @override
  _QuranReaderState createState() => _QuranReaderState();
}

class _QuranReaderState extends State<QuranReader> {
  bool _isLoading = true;
  double _fontSize = 22.0;
  List<String> _verses = [];
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadQuranContent();
  }

  Future<void> _loadQuranContent() async {
    // في التطبيق الحقيقي، هذا سيكون استعلامًا لقاعدة البيانات
    await Future.delayed(Duration(milliseconds: 500));

    if (widget.isJuz) {
      _verses = List.generate(
        20,
        (i) => 'نص آية من الجزء ${widget.index} - الآية ${i + 1}',
      );
    } else {
      // إذا كانت سورة الفاتحة
      if (widget.index == 1) {
        _verses = [
          "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ ١",
          "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ٢",
          "الرَّحْمَنِ الرَّحِيمِ ٣",
          "مَالِكِ يَوْمِ الدِّينِ ٤",
          "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ٥",
          "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ٦",
          "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ ٧",
        ];
      } else {
        _verses = List.generate(
          15,
          (i) => 'نص آية من سورة ${widget.title} - الآية ${i + 1}',
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked
            ? 'تمت إضافة ${widget.title} إلى المفضلة'
            : 'تمت إزالة ${widget.title} من المفضلة'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_outline),
            onPressed: _toggleBookmark,
            tooltip: 'إضافة إلى المفضلة',
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('زيادة حجم الخط'),
                onTap: () {
                  setState(() {
                    _fontSize += 2.0;
                  });
                },
              ),
              PopupMenuItem(
                child: Text('تقليل حجم الخط'),
                onTap: () {
                  setState(() {
                    _fontSize = (_fontSize - 2.0).clamp(14.0, 40.0);
                  });
                },
              ),
              PopupMenuItem(
                child: Text('مشاركة'),
                onTap: () {
                  // تنفيذ المشاركة
                },
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: _verses.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Text(
                      _verses[index],
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class QuranSearchDelegate extends SearchDelegate<String> {
  final List<String> surahs;

  QuranSearchDelegate(this.surahs);

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
    final results =
        query.isEmpty ? [] : surahs.where((s) => s.contains(query)).toList();

    return results.isEmpty
        ? Center(
            child: Text(
              query.isEmpty ? 'ابدأ البحث' : 'لا توجد نتائج لـ "$query"',
            ),
          )
        : ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final surahName = results[index];
              final surahIndex = surahs.indexOf(surahName);
              return ListTile(
                leading: CircleAvatar(
                  child: Text((surahIndex + 1).toString()),
                ),
                title: Text(surahName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuranReader(
                        title: surahName,
                        index: surahIndex + 1,
                      ),
                    ),
                  );
                },
              );
            },
          );
  }
}
