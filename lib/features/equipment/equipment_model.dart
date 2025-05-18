class Equipment {
  final int id;
  final String name;
  final String description;

  Equipment({required this.id, required this.name, required this.description});

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }
}
