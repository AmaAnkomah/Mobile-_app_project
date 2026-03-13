class Course {
  final String id;
  final String title;
  final String description;
  final String longDescription;
  final String instructorId;
  final String category;
  final String thumbnailUrl;
  final String videoUrl;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.longDescription,
    required this.instructorId,
    required this.category,
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  factory Course.fromJson(Map<String, dynamic> json, String docId) => Course(
    id: docId,
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    longDescription: json['long_description'] ?? '',
    instructorId: json['instructor_id'] ?? '',
    category: json['category'] ?? 'General',
    thumbnailUrl: json['thumbnail_url'] ?? '',
    videoUrl: json['video_url'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'long_description': longDescription,
    'instructor_id': instructorId,
    'category': category,
    'thumbnail_url': thumbnailUrl,
    'video_url': videoUrl,
  };
}
