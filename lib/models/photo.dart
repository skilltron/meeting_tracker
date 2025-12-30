class Photo {
  final String id;
  final String path;
  final String? url; // For web/network images
  final String? title;
  final String? description;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final Map<String, dynamic>? metadata; // EXIF data, etc.
  
  Photo({
    required this.id,
    required this.path,
    this.url,
    this.title,
    this.description,
    DateTime? createdAt,
    this.modifiedAt,
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();
  
  Photo copyWith({
    String? id,
    String? path,
    String? url,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Photo(
      id: id ?? this.id,
      path: path ?? this.path,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      metadata: metadata ?? this.metadata,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'url': url,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
  
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      path: json['path'],
      url: json['url'],
      title: json['title'],
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'])
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
