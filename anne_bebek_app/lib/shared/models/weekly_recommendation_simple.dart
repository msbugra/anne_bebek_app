import 'package:json_annotation/json_annotation.dart';

part 'weekly_recommendation_simple.g.dart';

@JsonSerializable()
class WeeklyRecommendationSimple {
  final int? id;
  final String title;
  final String description;
  final String category;
  final int weekNumber;
  final int ageYears;
  final List<String>? activities;
  final int? estimatedDuration;
  final DateTime createdAt;

  const WeeklyRecommendationSimple({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.weekNumber,
    required this.ageYears,
    this.activities,
    this.estimatedDuration,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory WeeklyRecommendationSimple.fromJson(Map<String, dynamic> json) =>
      _$WeeklyRecommendationSimpleFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$WeeklyRecommendationSimpleToJson(this);

  // Factory constructor from database map
  factory WeeklyRecommendationSimple.fromMap(Map<String, dynamic> map) {
    return WeeklyRecommendationSimple(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      weekNumber: map['week_number'] as int,
      ageYears: map['age_years'] as int,
      activities: map['activities'] != null
          ? List<String>.from(map['activities'] as List)
          : null,
      estimatedDuration: map['estimated_duration'] as int?,
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
      'week_number': weekNumber,
      'age_years': ageYears,
      'activities': activities,
      'estimated_duration': estimatedDuration,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Copy with method
  WeeklyRecommendationSimple copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    int? weekNumber,
    int? ageYears,
    List<String>? activities,
    int? estimatedDuration,
    DateTime? createdAt,
  }) {
    return WeeklyRecommendationSimple(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      weekNumber: weekNumber ?? this.weekNumber,
      ageYears: ageYears ?? this.ageYears,
      activities: activities ?? this.activities,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyRecommendationSimple &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.weekNumber == weekNumber &&
        other.ageYears == ageYears &&
        other.estimatedDuration == estimatedDuration;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      category,
      weekNumber,
      ageYears,
      estimatedDuration,
    );
  }

  @override
  String toString() {
    return 'WeeklyRecommendationSimple(id: $id, title: $title, category: $category, weekNumber: $weekNumber, ageYears: $ageYears)';
  }
}
