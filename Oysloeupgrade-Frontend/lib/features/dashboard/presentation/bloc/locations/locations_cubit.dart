import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/location_entity.dart';
import '../../../domain/usecases/get_locations_usecase.dart';
import 'locations_state.dart';

class LocationsCubit extends Cubit<LocationsState> {
  LocationsCubit(this._getLocations) : super(const LocationsState());

  final GetLocationsUseCase _getLocations;

  Future<void> fetch() async {
    print('LocationsCubit.fetch() called');
    if (state.isLoading) {
      print('LocationsCubit: Already loading, skipping');
      return;
    }
    if (state.hasData) {
      print('LocationsCubit: Already has data, skipping');
      return; // Only fetch once
    }

    print('LocationsCubit: Starting fetch...');
    emit(
      state.copyWith(
        status: LocationsStatus.loading,
        resetMessage: true,
      ),
    );

    print('LocationsCubit: Calling use case...');
    final result = await _getLocations();
    print('LocationsCubit: Use case returned');

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
        print('LocationsCubit: Received ${locations.length} locations');
        final regions = <String>{};
        for (var location in locations) {
          print('Location: id=${location.id}, name=${location.name}, region=${location.region}');
          if (location.region != null && location.region!.isNotEmpty) {
            regions.add(location.region!);
          }
        }

        print('LocationsCubit: Extracted ${regions.length} unique regions: $regions');

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
