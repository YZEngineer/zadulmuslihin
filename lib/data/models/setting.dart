class Setting {
  final int? id;
  final bool isDarkMode;
  final bool notification;
  final bool prayerNotification;

  Setting({this.id,required this.isDarkMode,required this.notification,required this.prayerNotification});

  factory Setting.fromMap(Map<String, dynamic> map) {
    return Setting(id: map['id'],isDarkMode: map['isDarkMode'],notification: map['notification'],prayerNotification: map['prayerNotification']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isDarkMode': isDarkMode,
      'notification': notification,
      'prayerNotification': prayerNotification,
    };
  }


}
