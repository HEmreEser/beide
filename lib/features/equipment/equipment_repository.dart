import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'equipment_model.dart';

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return EquipmentRepository();
});

class EquipmentRepository {
  Future<List<Equipment>> fetchAll() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/equipment'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Equipment.fromJson(e)).toList();
    } else {
      throw Exception("Geräte konnten nicht geladen werden");
    }
  }
}
