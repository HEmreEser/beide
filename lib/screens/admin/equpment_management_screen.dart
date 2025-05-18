import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';

class EquipmentManagementScreen extends ConsumerStatefulWidget {
  const EquipmentManagementScreen({super.key});

  @override
  ConsumerState<EquipmentManagementScreen> createState() =>
      _EquipmentManagementScreenState();
}

class _EquipmentManagementScreenState
    extends ConsumerState<EquipmentManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Freizeitsport';
  bool _isAvailable = true;

  final List<String> categories = [
    'Freizeitsport',
    'Fortbewegungsmittel',
    'Kleidung',
    'Training',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = categories.first;
      _isAvailable = true;
    });
  }

  Future<void> _createEquipment() async {
    if (_formKey.currentState!.validate()) {
      try {
        final equipment = await ApiService.createEquipment(
          name: _nameController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          available: _isAvailable,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Equipment "${equipment['name']}" erstellt!'),
              backgroundColor: Colors.green,
            ),
          );
          _resetForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Erstellen des Equipments'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Management'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.purple.shade900],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900.withOpacity(0.2),
              Colors.purple.shade900.withOpacity(0.2),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value?.isEmpty == true
                                      ? 'Name erforderlich'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Beschreibung',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator:
                              (value) =>
                                  value?.isEmpty == true
                                      ? 'Beschreibung erforderlich'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Kategorie',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Verfügbar'),
                          value: _isAvailable,
                          onChanged: (value) {
                            setState(() {
                              _isAvailable = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _createEquipment,
                  icon: const Icon(Icons.add),
                  label: const Text('Equipment erstellen'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
