import 'package:supabase_flutter/supabase_flutter.dart';

enum GroupType { public, private }
enum GroupCategory { 
  stocks, 
  crypto, 
  forex, 
  commodities, 
  options, 
  technicalAnalysis,
  fundamentalAnalysis,
  dayTrading,
  swingTrading
}

class Group {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final GroupType type;
  final GroupCategory category;
  final String? imageUrl;
  final DateTime createdAt;
  final int memberCount;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.type,
    required this.category,
    this.imageUrl,
    required this.createdAt,
    this.memberCount = 0,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      ownerId: map['owner_id'],
      type: GroupType.values.firstWhere(
        (e) => e.toString() == 'GroupType.${map['type']}',
      ),
      category: GroupCategory.values.firstWhere(
        (e) => e.toString() == 'GroupCategory.${map['category']}',
      ),
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
      memberCount: map['member_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'image_url': imageUrl,
    };
  }
}