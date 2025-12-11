import 'package:equatable/equatable.dart';

import '../../../domain/entities/location_entity.dart';

enum LocationsStatus { initial, loading, success, failure }

class LocationsState extends Equatable {
  const LocationsState({
    this.status = LocationsStatus.initial,
    this.locations = const <LocationEntity>[],
    this.regions = const <String>[],
    this.subLocationsStatus = LocationsStatus.initial,
    this.subLocations = const <LocationEntity>[],
    this.message,
  });

  final LocationsStatus status;
  final List<LocationEntity> locations;
  final List<String> regions;
  final LocationsStatus subLocationsStatus;
  final List<LocationEntity> subLocations;
  final String? message;

  bool get isLoading => status == LocationsStatus.loading;
  bool get hasError => status == LocationsStatus.failure;
  bool get hasData => locations.isNotEmpty;
  bool get hasRegions => regions.isNotEmpty;
  bool get isLoadingSubLocations =>
      subLocationsStatus == LocationsStatus.loading;
  bool get hasSubLocations => subLocations.isNotEmpty;

  LocationsState copyWith({
    LocationsStatus? status,
    List<LocationEntity>? locations,
    List<String>? regions,
    LocationsStatus? subLocationsStatus,
    List<LocationEntity>? subLocations,
    String? message,
    bool resetMessage = false,
  }) {
    return LocationsState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      regions: regions ?? this.regions,
      subLocationsStatus: subLocationsStatus ?? this.subLocationsStatus,
      subLocations: subLocations ?? this.subLocations,
      message: resetMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        locations,
        regions,
        subLocationsStatus,
        subLocations,
        message,
      ];
}
