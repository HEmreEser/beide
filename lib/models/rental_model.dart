class Rental {
  final int id;
  final int itemId;
  final String itemName;
  final int userId;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'ACTIVE', 'RETURNED', 'OVERDUE'
  final String? itemBrand;
  final String? itemSize;

  Rental({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.itemBrand,
    this.itemSize,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'],
      itemId: json['itemId'],
      itemName: json['itemName'],
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
      itemBrand: json['itemBrand'],
      itemSize: json['itemSize'],
    );
  }
}
