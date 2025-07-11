import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shipment.dart';
import '../providers/shipment_provider.dart';

class ShipmentScreen extends ConsumerWidget {
  const ShipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipmentsAsync = ref.watch(shipmentsProvider);

    return Scaffold(
      body: shipmentsAsync.when(
        data: (shipments) {
          if (shipments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No shipments available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create a new shipment or wait for available offers',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shipments.length,
            itemBuilder: (context, index) {
              final shipment = shipments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(
                      shipment.status == ShipmentStatus.available
                          ? Icons.search
                          : Icons.local_shipping,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    '${shipment.origin} → ${shipment.destination}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${shipment.price.toStringAsFixed(2)}'),
                      Text('Status: ${shipment.status.name}'),
                      Text('Created: ${shipment.createdAt.toString().split(' ')[0]}'),
                    ],
                  ),
                  trailing: shipment.status == ShipmentStatus.available
                      ? ElevatedButton(
                          onPressed: () {
                            // TODO: Implement bid functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bid functionality coming soon!'),
                              ),
                            );
                          },
                          child: const Text('Bid'),
                        )
                      : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading shipments',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(error.toString()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateShipmentDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateShipmentDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    String origin = '';
    String destination = '';
    double price = 0.0;
    String description = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Shipment'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Origin',
                    hintText: 'e.g., New York, NY',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter origin';
                    }
                    return null;
                  },
                  onSaved: (value) => origin = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    hintText: 'e.g., London, UK',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter destination';
                    }
                    return null;
                  },
                  onSaved: (value) => destination = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Price (\$)',
                    hintText: 'e.g., 50.00',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                  onSaved: (value) => price = double.parse(value ?? '0'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Package details, size, weight...',
                  ),
                  maxLines: 3,
                  onSaved: (value) => description = value ?? '',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                formKey.currentState?.save();
                
                final shipment = Shipment(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  origin: origin,
                  destination: destination,
                  price: price,
                  description: description,
                  status: ShipmentStatus.available,
                  createdAt: DateTime.now(),
                  senderId: 'current_user_id', // TODO: Get from auth
                );

                ref.read(shipmentsProvider.notifier).addShipment(shipment);
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shipment created successfully!'),
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}