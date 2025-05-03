class QuranVerses {
  final int? id;
  final String text;
  final String source;
  final String theme;

  QuranVerses({
    this.id ,
    required this.text,
    required this.source,
    required this.theme,
  });

  factory QuranVerses.fromMap(Map<String, dynamic> map) {
    return QuranVerses(
      id: map['id'],
      text: map['text'],
      source: map['source'],
      theme: map['theme'],
    );
  }

  Map<String, dynamic> toMap() {
    return {  
      'id': id,
      'text': text,
      'source': source,
      'theme': theme,
    };
  }
  QuranVerses copyWith({
    int? id,
    String? text,
    String? source,
    String? theme,
  }) {
    return QuranVerses(
      id: id ?? this.id,
      text: text ?? this.text,
      source: source ?? this.source,
      theme: theme ?? this.theme,
    );
  }


}