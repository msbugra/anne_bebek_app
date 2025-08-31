import 'package:json_annotation/json_annotation.dart';

part 'recommendation_model.g.dart';

@JsonSerializable()
class RecommendationModel {
  final int? id;
  final String title;
  final String description;
  final String category;
  final int dayNumber;
  final String? details;
  final String? scientificSource;
  final List<String>? benefits;
  final String? source;
  final DateTime createdAt;

  const RecommendationModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dayNumber,
    this.details,
    this.scientificSource,
    this.benefits,
    this.source,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory RecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendationModelFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$RecommendationModelToJson(this);

  // Factory constructor from database map
  factory RecommendationModel.fromMap(Map<String, dynamic> map) {
    return RecommendationModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      dayNumber: map['day_number'] as int,
      details: map['details'] as String?,
      scientificSource: map['scientific_source'] as String?,
      benefits: map['benefits'] != null
          ? List<String>.from(map['benefits'] as List)
          : null,
      source: map['source'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'day_number': dayNumber,
      'details': details,
      'scientific_source': scientificSource,
      'benefits': benefits,
      'source': source,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Copy with method
  RecommendationModel copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    int? dayNumber,
    String? details,
    String? scientificSource,
    List<String>? benefits,
    String? source,
    DateTime? createdAt,
  }) {
    return RecommendationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dayNumber: dayNumber ?? this.dayNumber,
      details: details ?? this.details,
      scientificSource: scientificSource ?? this.scientificSource,
      benefits: benefits ?? this.benefits,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendationModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.dayNumber == dayNumber &&
        other.details == details &&
        other.scientificSource == scientificSource &&
        other.source == source;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      category,
      dayNumber,
      details,
      scientificSource,
      source,
    );
  }

  @override
  String toString() {
    return 'RecommendationModel(id: $id, title: $title, category: $category, dayNumber: $dayNumber)';
  }
}
