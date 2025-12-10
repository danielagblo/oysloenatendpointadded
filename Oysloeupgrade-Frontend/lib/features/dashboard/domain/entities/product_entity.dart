import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  const ProductEntity({
    required this.id,
    required this.pid,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.status,
    required this.image,
    required this.images,
    required this.productFeatures,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.totalReports = 0,
    this.totalFavourites = 0,
    this.isFavourite = false,
    this.location,
    this.isTaken = false,
  });

  final int id;
  final String pid;
  final String name;
  final String description;
  final String price;
  final String type;
  final String status;
  final String image;
  final List<String> images;
  final List<String> productFeatures;
  final int category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalReports;
  final int totalFavourites;
  final bool isFavourite;
  final ProductLocation? location;
  final bool isTaken;

  @override
  List<Object?> get props => <Object?>[
        id,
        pid,
        name,
        description,
        price,
        type,
        status,
        image,
        images,
        productFeatures,
        category,
        createdAt,
        updatedAt,
        totalReports,
        totalFavourites,
        isFavourite,
        location,
        isTaken,
      ];
}

class ProductLocation extends Equatable {
  const ProductLocation({
    this.id,
    this.name,
    this.region,
  });

  final int? id;
  final String? name;
  final String? region;

  /// Returns a formatted label like "Kumasi, Ashanti" or the available part.
  String? get label {
    final String nameText = name?.trim() ?? '';
    final String regionText = region?.trim() ?? '';

    if (nameText.isEmpty && regionText.isEmpty) {
      return null;
    }
    if (nameText.isEmpty) {
      return regionText;
    }
    if (regionText.isEmpty) {
      return nameText;
    }
    return '$nameText, $regionText';
  }

  @override
  List<Object?> get props => <Object?>[id, name, region];
}
