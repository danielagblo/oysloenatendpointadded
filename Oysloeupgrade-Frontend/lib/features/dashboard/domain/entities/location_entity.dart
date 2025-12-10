import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  const LocationEntity({
    required this.id,
    required this.name,
    this.city,
    this.region,
    this.description,
  });

  final int id;
  final String name;
  final String? city;
  final String? region;
  final String? description;

  @override
  List<Object?> get props => [id, name, city, region, description];
}
