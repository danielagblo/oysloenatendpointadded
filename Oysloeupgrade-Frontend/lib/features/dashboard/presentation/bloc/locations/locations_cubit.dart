import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/location_entity.dart';
import '../../../domain/usecases/get_locations_usecase.dart';
import 'locations_state.dart';

class LocationsCubit extends Cubit<LocationsState> {
  LocationsCubit(this._getLocations) : super(const LocationsState());

  final GetLocationsUseCase _getLocations;

  Future<void> fetch() async {
    if (state.isLoading) return;
    if (state.hasData) return; // Only fetch once

    emit(
      state.copyWith(
        status: LocationsStatus.loading,
        resetMessage: true,
      ),
    );

    final result = await _getLocations();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LocationsStatus.failure,
          locations: const <LocationEntity>[],
          message: failure.message,
        ),
      ),
      (locations) {
        // Extract unique regions
        final regions = <String>{};
        for (var location in locations) {
          if (location.region != null && location.region!.isNotEmpty) {
            regions.add(location.region!);
          }
        }

        emit(
          state.copyWith(
            status: LocationsStatus.success,
            locations: locations,
            regions: regions.toList()..sort(),
            resetMessage: true,
          ),
        );
      },
    );
  }

  void filterByRegion(String region) {
    final filteredLocations =
        state.locations.where((location) => location.region == region).toList();

    emit(
      state.copyWith(
        subLocations: filteredLocations,
        subLocationsStatus: LocationsStatus.success,
      ),
    );
  }

  void clearSubLocations() {
    emit(
      state.copyWith(
        subLocationsStatus: LocationsStatus.initial,
        subLocations: const <LocationEntity>[],
      ),
    );
  }

  void clear() {
    emit(const LocationsState());
  }
}
