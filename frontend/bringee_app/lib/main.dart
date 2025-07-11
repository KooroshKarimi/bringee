import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'dart:convert';
import 'package:http/http.dart' as http;
=======
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/shipment_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/auth_provider.dart';
>>>>>>> 033c0c866550133c8a28156ddeb21326d2c77cab

void main() {
  runApp(const ProviderScope(child: BringeeApp()));
}

class BringeeApp extends ConsumerWidget {
  const BringeeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return MaterialApp(
<<<<<<< HEAD
      title: 'Bringee - Lieferdienst Plattform',
=======
      title: 'Bringee - Peer-to-Peer Logistik',
>>>>>>> 033c0c866550133c8a28156ddeb21326d2c77cab
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
<<<<<<< HEAD
      home: const BringeeHomePage(),
=======
      home: const MainScreen(),
>>>>>>> 033c0c866550133c8a28156ddeb21326d2c77cab
    );
  }
}

<<<<<<< HEAD
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
=======
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ShipmentsScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Start',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Sendungen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
>>>>>>> 033c0c866550133c8a28156ddeb21326d2c77cab
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
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
=======
        title: const Text('Bringee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Benachrichtigungen')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Willkommen bei Bringee!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Die Peer-to-Peer Logistikplattform',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Schnellaktionen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.add_box,
                    title: 'Sendung erstellen',
                    subtitle: 'Neue Sendung aufgeben',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateShipmentScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.search,
                    title: 'Sendungen finden',
                    subtitle: 'Als Transporteur',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FindShipmentsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent Activity
            const Text(
              'Letzte Aktivitäten',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _ActivityCard(
              title: 'Sendung #12345',
              subtitle: 'Von Berlin nach München',
              status: 'In Bearbeitung',
              statusColor: Colors.orange,
            ),
            const SizedBox(height: 8),
            _ActivityCard(
              title: 'Transport angenommen',
              subtitle: 'Sendung #12340',
              status: 'Unterwegs',
              statusColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

<<<<<<< HEAD
=======
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        ),
      ),
      home: authState.when(
        data: (user) => user != null ? const HomeScreen() : const AuthScreen(),
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => const AuthScreen(),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final String title;
  final String status;
  final String price;
  final String date;
  final Color statusColor;

  const _ShipmentCard({
    required this.title,
    required this.status,
    required this.price,
    required this.date,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            Icons.local_shipping,
            color: statusColor,
          ),
        ),
        title: Text(title),
        subtitle: Text('$date • $status'),
        trailing: Text(
          price,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        onTap: () {
          // TODO: Navigate to shipment details
        },
      ),
    );
  }
}

>>>>>>> origin/main
class ShipmentsScreen extends StatelessWidget {
  const ShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Sendungen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ShipmentCard(
            id: '12345',
            from: 'Berlin',
            to: 'München',
            status: 'In Bearbeitung',
            statusColor: Colors.orange,
            price: '€25.00',
            date: '15. Dez 2024',
          ),
          const SizedBox(height: 12),
          _ShipmentCard(
            id: '12340',
            from: 'Hamburg',
            to: 'Köln',
            status: 'Unterwegs',
            statusColor: Colors.blue,
            price: '€30.00',
            date: '14. Dez 2024',
          ),
          const SizedBox(height: 12),
          _ShipmentCard(
            id: '12335',
            from: 'Frankfurt',
            to: 'Düsseldorf',
            status: 'Zugestellt',
            statusColor: Colors.green,
            price: '€20.00',
            date: '13. Dez 2024',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateShipmentScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ChatCard(
            name: 'Max Mustermann',
            lastMessage: 'Wann können Sie die Sendung abholen?',
            time: '14:30',
            unread: 2,
            avatar: 'M',
          ),
          const SizedBox(height: 12),
          _ChatCard(
            name: 'Anna Schmidt',
            lastMessage: 'Sendung erfolgreich zugestellt!',
            time: '12:15',
            unread: 0,
            avatar: 'A',
          ),
          const SizedBox(height: 12),
          _ChatCard(
            name: 'Tom Weber',
            lastMessage: 'Können Sie morgen transportieren?',
            time: 'Gestern',
            unread: 1,
            avatar: 'T',
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Einstellungen')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text(
                'JD',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'john.doe@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            _ProfileMenuItem(
              icon: Icons.verified_user,
              title: 'Verifiziert',
              subtitle: 'Identität bestätigt',
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            _ProfileMenuItem(
              icon: Icons.star,
              title: 'Bewertung',
              subtitle: '4.8/5.0 (23 Bewertungen)',
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Text('4.8'),
                ],
              ),
            ),
            _ProfileMenuItem(
              icon: Icons.local_shipping,
              title: 'Sendungen',
              subtitle: '12 erfolgreich transportiert',
              trailing: const Text('12'),
            ),
            _ProfileMenuItem(
              icon: Icons.payment,
              title: 'Zahlungsmethoden',
              subtitle: 'Kreditkarte hinzugefügt',
              trailing: const Icon(Icons.chevron_right),
            ),
            _ProfileMenuItem(
              icon: Icons.help,
              title: 'Hilfe & Support',
              subtitle: 'FAQ und Kontakt',
              trailing: const Icon(Icons.chevron_right),
            ),
            _ProfileMenuItem(
              icon: Icons.logout,
              title: 'Abmelden',
              subtitle: 'Aus dem Konto ausloggen',
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widgets
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.local_shipping, color: statusColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
>>>>>>> 033c0c866550133c8a28156ddeb21326d2c77cab
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

class _ShipmentCard extends StatelessWidget {
  final String id;
  final String from;
  final String to;
  final String status;
  final Color statusColor;
  final String price;
  final String date;

  const _ShipmentCard({
    required this.id,
    required this.from,
    required this.to,
    required this.status,
    required this.statusColor,
    required this.price,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sendung #$id',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$from → $to'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final String avatar;

  const _ChatCard({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            avatar,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(name),
        subtitle: Text(lastMessage),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (unread > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  unread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}

// Placeholder screens
class CreateShipmentScreen extends StatelessWidget {
  const CreateShipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neue Sendung'),
      ),
      body: const Center(
        child: Text('Sendung erstellen - Coming Soon'),
      ),
    );
  }
}

class FindShipmentsScreen extends StatelessWidget {
  const FindShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sendungen finden'),
      ),
      body: const Center(
        child: Text('Sendungen finden - Coming Soon'),
      ),
    );
  }
}
