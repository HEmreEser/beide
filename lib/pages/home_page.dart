import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kreisel_frontend/models/user_model.dart';
import 'package:kreisel_frontend/models/item_model.dart';
import 'package:kreisel_frontend/models/rental_model.dart';
import 'package:kreisel_frontend/pages/login_page.dart';
import 'package:kreisel_frontend/pages/home_page.dart';
import 'package:kreisel_frontend/pages/my_rentals_page.dart';
import 'package:kreisel_frontend/services/api_service.dart';
import 'package:kreisel_frontend/main.dart';

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Item> _items = [];
  List<Item> _filteredItems = [];
  bool _isLoading = true;
  bool _showOnlyAvailable = true;
  String? _selectedGender;
  String? _selectedCategory;
  String? _selectedSubcategory;

  final Map<String, List<String>> categorySubcategories = {
    'KLEIDUNG': ['HOSEN', 'JACKEN'],
    'SCHUHE': ['STIEFEL', 'WANDERSCHUHE'],
    'ACCESSOIRES': ['MUETZEN', 'HANDSCHUHE', 'SCHALS', 'BRILLEN'],
    'TASCHEN': [],
    'EQUIPMENT': ['FLASCHEN', 'SKI', 'SNOWBOARDS', 'HELME'],
  };

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_filterItems);
  }

  Future<void> _loadItems() async {
    try {
      final items = await ApiService.getItems(
        location: widget.selectedLocation,
      );
      setState(() {
        _items = items;
        _isLoading = false;
      });
      _filterItems();
    } catch (e) {
      setState(() => _isLoading = false);
      _showAlert('Fehler', 'Items konnten nicht geladen werden');
    }
  }

  void _filterItems() {
    setState(() {
      _filteredItems =
          _items.where((item) {
            // Verfügbarkeitsfilter
            if (_showOnlyAvailable && !item.available) return false;

            // Suchfilter
            if (_searchController.text.isNotEmpty) {
              final query = _searchController.text.toLowerCase();
              if (!item.name.toLowerCase().contains(query) &&
                  !(item.brand?.toLowerCase().contains(query) ?? false) &&
                  !(item.description?.toLowerCase().contains(query) ?? false)) {
                return false;
              }
            }

            // Gender Filter
            if (_selectedGender != null && item.gender != _selectedGender)
              return false;

            // Category Filter
            if (_selectedCategory != null && item.category != _selectedCategory)
              return false;

            // Subcategory Filter
            if (_selectedSubcategory != null &&
                item.subcategory != _selectedSubcategory)
              return false;

            return true;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: Icon(
                          CupertinoIcons.back,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.locationDisplayName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => MyRentalsPage(),
                            ),
                          );
                        },
                        child: Icon(
                          CupertinoIcons.person_2,
                          color: Color(0xFF007AFF),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Suchen...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          CupertinoIcons.search,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Available Toggle
                  Row(
                    children: [
                      Text(
                        'Nur verfügbare:',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      CupertinoSwitch(
                        value: _showOnlyAvailable,
                        onChanged: (value) {
                          setState(() => _showOnlyAvailable = value);
                          _filterItems();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter Chips
            Container(
              height: 120,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gender Filter
                    Row(
                      children: [
                        _buildFilterChip('DAMEN', _selectedGender, (value) {
                          setState(
                            () =>
                                _selectedGender =
                                    _selectedGender == value ? null : value,
                          );
                          _filterItems();
                        }),
                        _buildFilterChip('HERREN', _selectedGender, (value) {
                          setState(
                            () =>
                                _selectedGender =
                                    _selectedGender == value ? null : value,
                          );
                          _filterItems();
                        }),
                        _buildFilterChip('UNISEX', _selectedGender, (value) {
                          setState(
                            () =>
                                _selectedGender =
                                    _selectedGender == value ? null : value,
                          );
                          _filterItems();
                        }),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Category Filter
                    Row(
                      children:
                          categorySubcategories.keys.map((category) {
                            return _buildFilterChip(
                              category,
                              _selectedCategory,
                              (value) {
                                setState(() {
                                  _selectedCategory =
                                      _selectedCategory == value ? null : value;
                                  _selectedSubcategory =
                                      null; // Reset subcategory
                                });
                                _filterItems();
                              },
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 8),
                    // Subcategory Filter
                    if (_selectedCategory != null &&
                        categorySubcategories[_selectedCategory]!.isNotEmpty)
                      Row(
                        children:
                            categorySubcategories[_selectedCategory]!.map((
                              subcategory,
                            ) {
                              return _buildFilterChip(
                                subcategory,
                                _selectedSubcategory,
                                (value) {
                                  setState(
                                    () =>
                                        _selectedSubcategory =
                                            _selectedSubcategory == value
                                                ? null
                                                : value,
                                  );
                                  _filterItems();
                                },
                              );
                            }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            // Items List
            Expanded(
              child:
                  _isLoading
                      ? Center(child: CupertinoActivityIndicator())
                      : _filteredItems.isEmpty
                      ? Center(
                        child: Text(
                          'Keine Items gefunden',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.all(24),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          return _buildItemCard(_filteredItems[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? selectedValue,
    Function(String) onTap,
  ) {
    final isSelected = selectedValue == label;
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isSelected ? Color(0xFF007AFF) : Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        minSize: 0,
        onPressed: () => onTap(label),
        child: Text(
          label.toLowerCase().replaceAll('_', ' '),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toLowerCase(),
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              item.available
                  ? Color(0xFF32D74B).withOpacity(0.3)
                  : Color(0xFFFF453A).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        item.available ? Color(0xFF32D74B) : Color(0xFFFF453A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.available ? 'Verfügbar' : 'Ausgeliehen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (item.brand != null)
              Text(
                item.brand!,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            if (item.size != null)
              Text(
                'Größe: ${item.size}',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            if (item.description != null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  item.description!,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(item.gender),
                _buildInfoChip(item.category),
                _buildInfoChip(item.subcategory),
                if (item.zustand != null) _buildInfoChip(item.zustand),
              ],
            ),
            if (item.available)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Container(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder:
                            (context) => RentItemDialog(
                              item: item,
                              onRented: _loadItems,
                            ),
                      );
                    },
                    child: Text(
                      'Ausleihen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }
}
