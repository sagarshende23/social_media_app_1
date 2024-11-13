import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app_1/features/market/models/market_data.dart';
import 'package:social_media_app_1/features/market/services/market_service.dart';

final marketDataProvider =
    StateNotifierProvider<MarketDataNotifier, AsyncValue<List<MarketData>>>(
        (ref) {
  return MarketDataNotifier();
});

class MarketDataNotifier extends StateNotifier<AsyncValue<List<MarketData>>> {
  final MarketService _marketService = MarketService();

  MarketDataNotifier() : super(const AsyncValue.loading()) {
    loadMarketData();
  }

  Future<void> loadMarketData() async {
    try {
      final data = await _marketService.fetchMarketData();
      state = AsyncValue.data(data);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // void startRealTimeUpdates() {
  //   _marketService.subscribeToMarketUpdates((data) {
  //     state = AsyncValue.data(data);
  //   });
  // }

  @override
  void dispose() {
    _marketService.dispose();
    super.dispose();
  }
}
