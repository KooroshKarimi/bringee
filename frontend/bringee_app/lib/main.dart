import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const BringeeApp());
}

class BringeeApp extends StatelessWidget {
  const BringeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bringee - Lieferdienst Plattform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BringeeHomePage(),
    );
  }
}

class BringeeHomePage extends StatefulWidget {
  const BringeeHomePage({super.key});

  @override
  _BringeeHomePageState createState() => _BringeeHomePageState();
}

class _BringeeHomePageState extends State<BringeeHomePage> {
  int _selectedIndex = 0;
  List<User> users = [];
  List<Shipment> shipments = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await Future.wait([
        _loadUsers(),
        _loadShipments(),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Daten: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://user-service-xxxxx-ew.a.run.app/api/users'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            users = (data['users'] as List)
                .map((user) => User.fromJson(user))
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _loadShipments() async {
    try {
      final response = await http.get(
        Uri.parse('https://shipment-service-xxxxx-ew.a.run.app/api/shipments'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            shipments = (data['shipments'] as List)
                .map((shipment) => Shipment.fromJson(shipment))
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error loading shipments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bringee - Lieferdienst Plattform'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Benutzer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Sendungen',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildUsersTab();
      case 2:
        return _buildShipmentsTab();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Willkommen bei Bringee',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ihre Lieferdienst-Plattform für sichere und schnelle Sendungen',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.people, size: 48, color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(
                          '${users.length}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text('Registrierte Benutzer'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.local_shipping, size: 48, color: Colors.green),
                        const SizedBox(height: 8),
                        Text(
                          '${shipments.length}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text('Aktive Sendungen'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Neueste Sendungen',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...shipments.take(3).map((shipment) => ListTile(
                    leading: Icon(Icons.local_shipping),
                    title: Text(shipment.title),
                    subtitle: Text('${shipment.fromAddress} → ${shipment.toAddress}'),
                    trailing: Text('€${shipment.price.toStringAsFixed(2)}'),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.username[0].toUpperCase()),
            ),
            title: Text(user.username),
            subtitle: Text(user.email),
            trailing: Chip(
              label: Text(user.role),
              backgroundColor: user.role == 'admin' ? Colors.red : Colors.green,
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShipmentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shipments.length,
      itemBuilder: (context, index) {
        final shipment = shipments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getStatusIcon(shipment.status),
              color: _getStatusColor(shipment.status),
            ),
            title: Text(shipment.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${shipment.fromAddress} → ${shipment.toAddress}'),
                Text('Gewicht: ${shipment.weight}kg'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${shipment.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(shipment.status),
                  backgroundColor: _getStatusColor(shipment.status),
                  labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'available':
        return Icons.inventory;
      case 'in_transit':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.blue;
      case 'in_transit':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String created;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.created,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      created: json['created'] ?? '',
    );
  }
}

class Shipment {
  final String id;
  final String title;
  final String description;
  final String fromAddress;
  final String toAddress;
  final String status;
  final double price;
  final double weight;
  final String userId;
  final String created;
  final String updated;

  Shipment({
    required this.id,
    required this.title,
    required this.description,
    required this.fromAddress,
    required this.toAddress,
    required this.status,
    required this.price,
    required this.weight,
    required this.userId,
    required this.created,
    required this.updated,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fromAddress: json['from_address'] ?? '',
      toAddress: json['to_address'] ?? '',
      status: json['status'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      userId: json['user_id'] ?? '',
      created: json['created'] ?? '',
      updated: json['updated'] ?? '',
    );
  }
}
