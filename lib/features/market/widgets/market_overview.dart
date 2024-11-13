import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app_1/features/market/models/market_data.dart';
import 'package:social_media_app_1/features/market/providers/market_provider.dart';

class MarketOverview extends ConsumerWidget {
  const MarketOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketDataAsync = ref.watch(marketDataProvider);

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: marketDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (marketData) => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: marketData.length,
          itemBuilder: (context, index) {
            final data = marketData[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 140,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '\$${data.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Row(
                      children: [
                        Icon(
                          data.change >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: data.trendColor,
                          size: 16,
                        ),
                        Text(
                          '${data.change.toStringAsFixed(2)} (${data.changePercentage.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            color: data.trendColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
