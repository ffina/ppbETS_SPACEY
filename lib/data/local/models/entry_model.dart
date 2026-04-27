class EntryModel {
  final String id;
  final String userId;
  final String title;
  final String? note;
  final String? category;
  final String? mood;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? localImagePath;
  final String? remoteImageUrl;
  final DateTime createdAt;
  final bool isSynced;

  EntryModel({
    required this.id,
    required this.userId,
    required this.title,
    this.note,
    this.category,
    this.mood,
    this.latitude,
    this.longitude,
    this.locationName,
    this.localImagePath,
    this.remoteImageUrl,
    required this.createdAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'note': note,
    'category': category,
    'mood': mood,
    'latitude': latitude,
    'longitude': longitude,
    'locationName': locationName,
    'localImagePath': localImagePath,
    'remoteImageUrl': remoteImageUrl,
    'createdAt': createdAt.toIso8601String(),
    'isSynced': isSynced ? 1 : 0,
  };

  factory EntryModel.fromMap(Map<String, dynamic> map) => EntryModel(
    id: map['id'],
    userId: map['userId'],
    title: map['title'],
    note: map['note'],
    category: map['category'],
    mood: map['mood'],
    latitude: map['latitude'],
    longitude: map['longitude'],
    locationName: map['locationName'],
    localImagePath: map['localImagePath'],
    remoteImageUrl: map['remoteImageUrl'],
    createdAt: DateTime.parse(map['createdAt']),
    isSynced: map['isSynced'] == 1,
  );

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'title': title,
    'note': note,
    'category': category,
    'mood': mood,
    'latitude': latitude,
    'longitude': longitude,
    'locationName': locationName,
    'remoteImageUrl': remoteImageUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  EntryModel copyWith({
    String? remoteImageUrl,
    bool? isSynced,
    String? note,
    String? title,
    String? category,
    String? mood,
  }) => EntryModel(
    id: id,
    userId: userId,
    title: title ?? this.title,
    note: note ?? this.note,
    category: category ?? this.category,
    mood: mood ?? this.mood,
    latitude: latitude,
    longitude: longitude,
    locationName: locationName,
    localImagePath: localImagePath,
    remoteImageUrl: remoteImageUrl ?? this.remoteImageUrl,
    createdAt: createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
}