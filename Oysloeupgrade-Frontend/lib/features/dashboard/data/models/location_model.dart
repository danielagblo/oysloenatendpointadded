import '../../domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.id,
    required super.name,
    super.city,
    super.region,
    super.description,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int? ?? 0,
      name: _resolveString(json['name']) ?? '',
      city: _resolveString(json['city']),
      region: _resolveString(json['region']),
      description: _resolveString(json['description']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (city != null) 'city': city,
      if (region != null) 'region': region,
      if (description != null) 'description': description,
    };
  }

  static String? _resolveString(dynamic value) {
    if (value == null) return null;
    final String resolved = value.toString().trim();
    return resolved.isEmpty ? null : resolved;
  }
}
