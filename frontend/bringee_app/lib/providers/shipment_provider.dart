import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shipment.dart';

class ShipmentsNotifier extends StateNotifier<AsyncValue<List<Shipment>>> {
  ShipmentsNotifier() : super(const AsyncValue.loading()) {
    _loadInitialShipments();
  }

  void _loadInitialShipments() {
    // TODO: Load from backend API
    // For now, we'll start with an empty list
    state = const AsyncValue.data([]);
  }

  void addShipment(Shipment shipment) {
    state.whenData((shipments) {
      state = AsyncValue.data([shipment, ...shipments]);
    });
  }

  void updateShipment(Shipment updatedShipment) {
    state.whenData((shipments) {
      final updatedShipments = shipments.map((shipment) {
        return shipment.id == updatedShipment.id ? updatedShipment : shipment;
      }).toList();
      state = AsyncValue.data(updatedShipments);
    });
  }

  void removeShipment(String shipmentId) {
    state.whenData((shipments) {
      final filteredShipments = shipments
          .where((shipment) => shipment.id != shipmentId)
          .toList();
      state = AsyncValue.data(filteredShipments);
    });
  }

  Future<void> refreshShipments() async {
    state = const AsyncValue.loading();
    try {
      // TODO: Fetch from backend API
      await Future.delayed(const Duration(seconds: 1));
      state = const AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final shipmentsProvider = StateNotifierProvider<ShipmentsNotifier, AsyncValue<List<Shipment>>>(
  (ref) => ShipmentsNotifier(),
);