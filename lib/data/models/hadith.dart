class Hadith {
  final int? id;
  final String content;
  final String? narrator;
  final String? source;
  final String? book;
  final String? chapter;
  final String? hadithNumber;

  Hadith({
    this.id,
    required this.content,
    this.narrator,
    this.source,
    this.book,
    this.chapter,
    this.hadithNumber,
  }) {
    if (content.isEmpty) {
      throw ArgumentError('محتوى الحديث لا يمكن أن يكون فارغاً');
    }
  }

  factory Hadith.fromMap(Map<String, dynamic> map) {
    if (map['content'] == null) {
      throw ArgumentError('البيانات غير كاملة: يجب توفير محتوى الحديث');
    }

    return Hadith(
      id: map['id'],
      content: map['content'],
      narrator: map['narrator'],
      source: map['source'],
      book: map['book'],
      chapter: map['chapter'],
      hadithNumber: map['hadithNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'narrator': narrator,
      'source': source,
      'book': book,
      'chapter': chapter,
      'hadithNumber': hadithNumber,
    };
  }

  Hadith copyWith({
    int? id,
    String? content,
    String? narrator,
    String? source,
    String? book,
    String? chapter,
    String? hadithNumber,
  }) {
    return Hadith(
      id: id ?? this.id,
      content: content ?? this.content,
      narrator: narrator ?? this.narrator,
      source: source ?? this.source,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      hadithNumber: hadithNumber ?? this.hadithNumber,
    );
  }

  String get citation {
    List<String> parts = [];
    if (narrator != null && narrator!.isNotEmpty) {
      parts.add('رواه $narrator');
    }
    if (source != null && source!.isNotEmpty) {
      parts.add(source!);
    }
    if (book != null && book!.isNotEmpty) {
      parts.add(book!);
    }
    if (hadithNumber != null && hadithNumber!.isNotEmpty) {
      parts.add('رقم $hadithNumber');
    }
    
    return parts.join('، ');
  }

  @override
  String toString() {
    return 'Hadith(id: $id, content: ${content.substring(0, content.length > 30 ? 30 : content.length)}..., '
        'narrator: $narrator, source: $source)';
  }
}
