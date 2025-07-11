import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/shipment_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: BringeeApp()));
}

class BringeeApp extends ConsumerWidget {
  const BringeeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return MaterialApp(
      title: 'Bringee - Peer-to-Peer Logistik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: authState.when(
        data: (user) => user != null ? const MainScreen() : const AuthScreen(),
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
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Max Mustermann',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'max.mustermann@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            // Profile Options
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Profil bearbeiten'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil bearbeiten')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Sicherheit'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sicherheit')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Benachrichtigungen'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Benachrichtigungen')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Hilfe & Support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hilfe & Support')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Über Bringee'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Über Bringee')),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abgemeldet')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Abmelden'),
              ),
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
          ),
        ),
      ),
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
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(name),
        subtitle: Text(lastMessage),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chat mit $name öffnen')),
          );
        },
      ),
    );
  }
}
