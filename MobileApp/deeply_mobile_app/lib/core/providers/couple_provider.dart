import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/couple.dart';
import '../../data/models/dtos.dart';
import '../../data/services/couple_service.dart';
import 'service_providers.dart';

// Couple State
class CoupleState {
  final bool isLoading;
  final Couple? couple;
  final String? error;

  CoupleState({this.isLoading = false, this.couple, this.error});

  CoupleState copyWith({bool? isLoading, Couple? couple, String? error}) {
    return CoupleState(
      isLoading: isLoading ?? this.isLoading,
      couple: couple ?? this.couple,
      error: error ?? this.error,
    );
  }
}

class CoupleNotifier extends StateNotifier<CoupleState> {
  final CoupleService coupleService;

  CoupleNotifier(this.coupleService) : super(CoupleState());

  Future<void> createCouple(String? coupleName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final couple = await coupleService.createCouple(
        CreateCoupleRequest(coupleName: coupleName),
      );
      state = state.copyWith(couple: couple, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> loadCouple() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final couple = await coupleService.getCouple();
      state = state.copyWith(couple: couple, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> joinCouple(String coupleCode) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final couple = await coupleService.joinCouple(
        JoinCoupleRequest(coupleCode: coupleCode),
      );
      state = state.copyWith(couple: couple, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final coupleProvider = StateNotifierProvider<CoupleNotifier, CoupleState>((
  ref,
) {
  final coupleService = ref.watch(coupleServiceProvider);
  return CoupleNotifier(coupleService);
});
