import 'dart:async';
import 'package:social_media_app_1/features/market/models/market_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarketService {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _marketChannel;

  Future<List<MarketData>> fetchMarketData() async {
    // Simulated market data for demonstration
    // In production, replace with actual API calls to financial data providers
    return [
      MarketData(
        symbol: "SPY",
        price: 470.25,
        change: 2.35,
        changePercentage: 0.5,
      ),
      MarketData(
        symbol: "QQQ",
        price: 390.80,
        change: -1.20,
        changePercentage: -0.3,
      ),
      MarketData(
        symbol: "BTC/USD",
        price: 43250.00,
        change: 1150.00,
        changePercentage: 2.7,
      ),
      MarketData(
        symbol: "ETH/USD",
        price: 2280.50,
        change: 45.30,
        changePercentage: 2.0,
      ),
    ];
  }

  // void subscribeToMarketUpdates(void Function(List<MarketData>) onData) {
  //   _marketChannel = _supabase.channel('market_updates')
  //     ..subscribe((status) {
  //       if (status == 'SUBSCRIBED') {
  //         // In production, implement real-time market data updates
  //         // For now, simulate updates every 5 seconds
  //         Timer.periodic(const Duration(seconds: 5), (_) async {
  //           final data = await fetchMarketData();
  //           onData(data);
  //         });
  //       }
  //     });
  // }

  void dispose() {
    _marketChannel?.unsubscribe();
  }
}
