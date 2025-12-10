import 'package:equatable/equatable.dart';

import '../../../domain/entities/location_entity.dart';

enum LocationsStatus { initial, loading, success, failure }

class LocationsState extends Equatable {
  const LocationsState({
    this.status = LocationsStatus.initial,
    this.locations = const <LocationEntity>[],
    this.message,
  });

  final LocationsStatus status;
  final List<LocationEntity> locations;
  final String? message;

  bool get isLoading => status == LocationsStatus.loading;
  bool get hasError => status == LocationsStatus.failure;
  bool get hasData => locations.isNotEmpty;

  LocationsState copyWith({
    LocationsStatus? status,
    List<LocationEntity>? locations,
    String? message,
    bool resetMessage = false,
  }) {
    return LocationsState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      message: resetMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, locations, message];
}
