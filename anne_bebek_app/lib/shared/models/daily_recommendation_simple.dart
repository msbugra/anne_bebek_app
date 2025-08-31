import 'package:json_annotation/json_annotation.dart';

part 'daily_recommendation_simple.g.dart';

@JsonSerializable()
class DailyRecommendationSimple {
  final int? id;
  final String title;
  final String description;
  final String category;
  final int dayNumber;
  final DateTime createdAt;

  const DailyRecommendationSimple({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dayNumber,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory DailyRecommendationSimple.fromJson(Map<String, dynamic> json) =>
      _$DailyRecommendationSimpleFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$DailyRecommendationSimpleToJson(this);

  // Factory constructor from database map
  factory DailyRecommendationSimple.fromMap(Map<String, dynamic> map) {
    return DailyRecommendationSimple(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      dayNumber: map['day_number'] as int,
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
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Copy with method
  DailyRecommendationSimple copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    int? dayNumber,
    DateTime? createdAt,
  }) {
    return DailyRecommendationSimple(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dayNumber: dayNumber ?? this.dayNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyRecommendationSimple &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.dayNumber == dayNumber;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, description, category, dayNumber);
  }

  @override
  String toString() {
    return 'DailyRecommendationSimple(id: $id, title: $title, category: $category, dayNumber: $dayNumber)';
  }
}
