enum ShipmentStatus {
  available,
  inProgress,
  delivered,
  cancelled,
}

class Shipment {
  final String id;
  final String origin;
  final String destination;
  final double price;
  final String description;
  final ShipmentStatus status;
  final DateTime createdAt;
  final String senderId;
  final String? transporterId;
  final DateTime? acceptedAt;
  final DateTime? deliveredAt;

  Shipment({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.senderId,
    this.transporterId,
    this.acceptedAt,
    this.deliveredAt,
  });

  Shipment copyWith({
    String? id,
    String? origin,
    String? destination,
    double? price,
    String? description,
    ShipmentStatus? status,
    DateTime? createdAt,
    String? senderId,
    String? transporterId,
    DateTime? acceptedAt,
    DateTime? deliveredAt,
  }) {
    return Shipment(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      price: price ?? this.price,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      senderId: senderId ?? this.senderId,
      transporterId: transporterId ?? this.transporterId,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origin': origin,
      'destination': destination,
      'price': price,
      'description': description,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'senderId': senderId,
      'transporterId': transporterId,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'],
      origin: json['origin'],
      destination: json['destination'],
      price: json['price'].toDouble(),
      description: json['description'],
      status: ShipmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      senderId: json['senderId'],
      transporterId: json['transporterId'],
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
    );
  }
}