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
      (locations) => emit(
        state.copyWith(
          status: LocationsStatus.success,
          locations: locations,
          resetMessage: true,
        ),
      ),
    );
  }

  void clear() {
    emit(const LocationsState());
  }
}
