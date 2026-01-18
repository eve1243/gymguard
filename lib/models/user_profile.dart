class UserProfile {
  final String id;
  final String name;
  final int age;
  final double weight;
  final List<String> recentHistory;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.weight,
    required this.recentHistory,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'weight': weight,
    'recentHistory': recentHistory,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      weight: json['weight'],
      recentHistory: List<String>.from(json['recentHistory']),
    );
  }
}
