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
  });

  factory Hadith.fromMap(Map<String, dynamic> map) {
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
}
