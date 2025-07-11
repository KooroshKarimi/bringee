import 'package:flutter/material.dart';

void main() {
  runApp(const BringeeApp());
}

class BringeeApp extends StatelessWidget {
  const BringeeApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const MainScreen(),
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
              // TODO: Implement notifications
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
              'Willkommen bei Bringee',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Die Peer-to-Peer Logistikplattform für sichere und kostengünstige Sendungen.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: 'Sendung erstellen',
                    subtitle: 'Neue Sendung aufgeben',
                    icon: Icons.add_box,
                    color: Colors.blue,
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
                    title: 'Transport anbieten',
                    subtitle: 'Als Transporteur tätig werden',
                    icon: Icons.directions_car,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AvailableShipmentsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Aktuelle Sendungen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ShipmentCard(
              title: 'Laptop nach Berlin',
              status: 'In Bearbeitung',
              price: '€45',
              date: '15. Jan 2025',
              statusColor: Colors.orange,
            ),
            const SizedBox(height: 12),
            _ShipmentCard(
              title: 'Dokumente nach München',
              status: 'Zugestellt',
              price: '€25',
              date: '12. Jan 2025',
              statusColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

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

class ShipmentsScreen extends StatelessWidget {
  const ShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Sendungen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ShipmentCard(
            title: 'Laptop nach Berlin',
            status: 'In Bearbeitung',
            price: '€45',
            date: '15. Jan 2025',
            statusColor: Colors.orange,
          ),
          const SizedBox(height: 12),
          _ShipmentCard(
            title: 'Dokumente nach München',
            status: 'Zugestellt',
            price: '€25',
            date: '12. Jan 2025',
            statusColor: Colors.green,
          ),
          const SizedBox(height: 12),
          _ShipmentCard(
            title: 'Paket nach Hamburg',
            status: 'In Transit',
            price: '€35',
            date: '10. Jan 2025',
            statusColor: Colors.blue,
          ),
        ],
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
            lastMessage: 'Hallo, wann können wir uns treffen?',
            time: '14:30',
            unread: 2,
          ),
          const SizedBox(height: 12),
          _ChatCard(
            name: 'Anna Schmidt',
            lastMessage: 'Perfekt, bis später am Flughafen!',
            time: '12:15',
            unread: 0,
          ),
        ],
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;

  const _ChatCard({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(name[0]),
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
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to chat detail
        },
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
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          const Text(
            'Max Mustermann',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'max.mustermann@email.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _ProfileMenuItem(
            icon: Icons.verified,
            title: 'Verifiziert',
            subtitle: 'Identität bestätigt',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.star,
            title: 'Bewertung',
            subtitle: '4.8/5 (12 Bewertungen)',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.local_shipping,
            title: 'Abgeschlossene Sendungen',
            subtitle: '8 Sendungen',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          const Divider(),
          _ProfileMenuItem(
            icon: Icons.help,
            title: 'Hilfe & Support',
            subtitle: 'FAQ und Kontakt',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.privacy_tip,
            title: 'Datenschutz',
            subtitle: 'Datenschutzerklärung',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.logout,
            title: 'Abmelden',
            subtitle: 'Konto verlassen',
            onTap: () {
              // TODO: Implement logout
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class CreateShipmentScreen extends StatefulWidget {
  const CreateShipmentScreen({super.key});

  @override
  _CreateShipmentScreenState createState() => _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends State<CreateShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController();
  final _recipientAddressController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemValueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neue Sendung'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Empfänger-Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientNameController,
              decoration: const InputDecoration(
                labelText: 'Name des Empfängers',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie den Namen ein';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientAddressController,
              decoration: const InputDecoration(
                labelText: 'Adresse des Empfängers',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie die Adresse ein';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientPhoneController,
              decoration: const InputDecoration(
                labelText: 'Telefonnummer des Empfängers',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie die Telefonnummer ein';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Sendungs-Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _itemDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Beschreibung des Inhalts',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie eine Beschreibung ein';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _itemValueController,
              decoration: const InputDecoration(
                labelText: 'Wert der Sendung (€)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie den Wert ein';
                }
                if (double.tryParse(value) == null) {
                  return 'Bitte geben Sie eine gültige Zahl ein';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // TODO: Implement shipment creation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sendung erfolgreich erstellt!'),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Sendung erstellen',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientAddressController.dispose();
    _recipientPhoneController.dispose();
    _itemDescriptionController.dispose();
    _itemValueController.dispose();
    super.dispose();
  }
}

class AvailableShipmentsScreen extends StatelessWidget {
  const AvailableShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verfügbare Sendungen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AvailableShipmentCard(
            title: 'Laptop nach Berlin',
            description: 'Kleiner Laptop, gut verpackt',
            price: '€45',
            from: 'München',
            to: 'Berlin',
            date: '20. Jan 2025',
          ),
          const SizedBox(height: 12),
          _AvailableShipmentCard(
            title: 'Dokumente nach Hamburg',
            description: 'Wichtige Unterlagen',
            price: '€30',
            from: 'Frankfurt',
            to: 'Hamburg',
            date: '22. Jan 2025',
          ),
          const SizedBox(height: 12),
          _AvailableShipmentCard(
            title: 'Geschenk nach Köln',
            description: 'Kleines Paket, zerbrechlich',
            price: '€25',
            from: 'Düsseldorf',
            to: 'Köln',
            date: '25. Jan 2025',
          ),
        ],
      ),
    );
  }
}

class _AvailableShipmentCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String from;
  final String to;
  final String date;

  const _AvailableShipmentCard({
    required this.title,
    required this.description,
    required this.price,
    required this.from,
    required this.to,
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('$from → $to'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(date),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Show shipment details
                    },
                    child: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Accept shipment
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sendung angenommen!'),
                        ),
                      );
                    },
                    child: const Text('Annehmen'),
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
