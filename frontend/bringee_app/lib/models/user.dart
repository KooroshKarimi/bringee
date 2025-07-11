enum UserType { sender, transporter }

class User {
  final String id;
  final String email;
  final String name;
  final bool isVerified;
  final UserType userType;
  final String? profileImage;
  final double? rating;
  final int? completedShipments;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.isVerified,
    required this.userType,
    this.profileImage,
    this.rating,
    this.completedShipments,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    bool? isVerified,
    UserType? userType,
    String? profileImage,
    double? rating,
    int? completedShipments,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isVerified: isVerified ?? this.isVerified,
      userType: userType ?? this.userType,
      profileImage: profileImage ?? this.profileImage,
      rating: rating ?? this.rating,
      completedShipments: completedShipments ?? this.completedShipments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isVerified': isVerified,
      'userType': userType.name,
      'profileImage': profileImage,
      'rating': rating,
      'completedShipments': completedShipments,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      isVerified: json['isVerified'],
      userType: UserType.values.firstWhere(
        (e) => e.name == json['userType'],
      ),
      profileImage: json['profileImage'],
      rating: json['rating']?.toDouble(),
      completedShipments: json['completedShipments'],
    );
  }
}