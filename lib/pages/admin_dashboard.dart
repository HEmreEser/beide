import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kreisel_frontend/services/admin_service.dart';
import 'package:kreisel_frontend/models/item_model.dart';
import 'package:kreisel_frontend/models/rental_model.dart';
import 'package:kreisel_frontend/models/user_model.dart';
import 'package:kreisel_frontend/pages/login_page.dart'; // Add this import

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedTab = 0;
  bool _isLoading = false;
  List<Item> _items = [];
  List<Rental> _rentals = [];
  List<User> _users = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      switch (_selectedTab) {
        case 0:
          _items = await AdminService.getAllItems();
          break;
        case 1:
          _rentals = await AdminService.getAllRentals();
          break;
        case 2:
          _users = await AdminService.getAllUsers();
          break;
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation Buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildNavButton('Items', 0),
                SizedBox(width: 8),
                _buildNavButton('Rentals', 1),
                SizedBox(width: 8),
                _buildNavButton('Users', 2),
              ],
            ),
          ),

          // Search Bar
          if (_selectedTab > 0) // Only show for rentals and users
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoSearchTextField(
                controller: _searchController,
                onSubmitted: _handleSearch,
                placeholder: 'Suche...',
                style: TextStyle(color: Colors.white),
              ),
            ),

          Expanded(
            child: _isLoading 
              ? Center(child: CupertinoActivityIndicator())
              : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 0 ? FloatingActionButton(
        backgroundColor: Color(0xFF007AFF),
        child: Icon(Icons.add),
        onPressed: _createItem,
      ) : null,
    );
  }

  Widget _buildNavButton(String title, int index) {
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.all(12),
        color: _selectedTab == index ? Color(0xFF007AFF) : Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
        onPressed: () {
          setState(() => _selectedTab = index);
          _searchController.clear();
          _loadData();
        },
        child: Text(title),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildItemsList();
      case 1:
        return _buildRentalsList();
      case 2:
        return _buildUsersList();
      default:
        return Container();
    }
  }

  Widget _buildItemsList() {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(_items[index].name, style: TextStyle(color: Colors.white)),
        subtitle: Text(_items[index].location, style: TextStyle(color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editItem(_items[index]),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem(_items[index].id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalsList() {
    return ListView.builder(
      itemCount: _rentals.length,
      itemBuilder: (context, index) => ListTile(
        title: Text('Rental #${_rentals[index].id}', style: TextStyle(color: Colors.white)),
        subtitle: Text(
          'User: ${_rentals[index].userId}\nItem: ${_rentals[index].itemId}',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(_users[index].fullName, style: TextStyle(color: Colors.white)),
        subtitle: Text(_users[index].email, style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      _loadData();
      return;
    }

    setState(() => _isLoading = true);
    try {
      switch (_selectedTab) {
        case 1: // Rentals
          // Implement rental search
          break;
        case 2: // Users
          // Implement user search
          break;
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  Future<void> _createItem() async {
    // Implementation for creating an item
  }

  Future<void> _editItem(Item item) async {
    // Implementation for editing an item
  }

  Future<void> _deleteItem(int id) async {
    try {
      await AdminService.deleteItem(id);
      _loadData();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _showUserRentals(int userId) async {
    try {
      final rental = await AdminService.getRentalById(userId);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('User Rentals'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rental #${rental.id}: Item ${rental.itemId}')
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Error'),
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