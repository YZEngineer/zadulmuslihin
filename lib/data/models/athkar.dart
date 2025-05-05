class Athkar {
  final int? id;
  final String content;
  final String? title;

  Athkar({this.id,required this.content,this.title,}) {
    if (content.isEmpty) {
      throw ArgumentError('محتوى الذكر لا يمكن أن يكون فارغاً');}}

  factory Athkar.fromMap(Map<String, dynamic> map) {
    if (map['content'] == null) {
      throw ArgumentError('البيانات غير كاملة: يجب توفير محتوى الذكر');
    }

    return Athkar(id: map['id'],content: map['content'],title: map['title']);}

  Map<String, dynamic> toMap() {
    return {'id': id,'content': content,'title': title};}

  Athkar copyWith({int? id,String? content,String? title,}) {
    return Athkar(id: id ?? this.id,
    content: content ?? this.content,title: title ?? this.title);
  }

  @override
  String toString() {
    return 'Athkar(id: $id, content: $content, title: $title)';
  }
}
