import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/beer_repository.dart';
import '../models/beer_item.dart';

/// Provider for BeerRepository singleton
final beerRepositoryProvider = Provider<BeerRepository>((ref) {
  return BeerRepository();
});

/// Provider for beer list with API integration and caching
final beerListProvider = StateNotifierProvider<BeerListNotifier, AsyncValue<List<BeerItem>>>((ref) {
  final repository = ref.watch(beerRepositoryProvider);
  return BeerListNotifier(repository);
});

/// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered beer list based on search query
final filteredBeerListProvider = Provider<AsyncValue<List<BeerItem>>>((ref) {
  final beerListAsync = ref.watch(beerListProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return beerListAsync.whenData((beers) {
    if (searchQuery.isEmpty) {
      return beers;
    }

    final query = searchQuery.toLowerCase();
    return beers.where((beer) {
      return beer.name.toLowerCase().contains(query) ||
             beer.brand.toLowerCase().contains(query);
    }).toList();
  });
});

/// State notifier for managing beer list with repository
class BeerListNotifier extends StateNotifier<AsyncValue<List<BeerItem>>> {
  final BeerRepository _repository;

  BeerListNotifier(this._repository) : super(const AsyncValue.loading()) {
    // Load beers on initialization
    loadBeers();
  }

  /// Load beers from repository (cache or API)
  Future<void> loadBeers({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();

    try {
      final beers = await _repository.getBeers(forceRefresh: forceRefresh);
      state = AsyncValue.data(beers);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh beers from API
  Future<void> refresh() async {
    await loadBeers(forceRefresh: true);
  }

  /// Add a new beer (calls API and updates cache)
  Future<BeerItem> addBeer({
    required String brand,
    required String name,
    String? style,
  }) async {
    try {
      final newBeer = await _repository.createBeer(
        brand: brand,
        name: name,
        style: style,
      );

      // Update state with new beer
      state.whenData((currentBeers) {
        state = AsyncValue.data([...currentBeers, newBeer]);
      });

      return newBeer;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Increment beer count (optimistic update)
  void incrementBeer(int id) {
    state = state.whenData((beers) {
      return [
        for (final beer in beers)
          if (beer.id == id)
            beer.copyWith(count: beer.count + 1)
          else
            beer,
      ];
    });

    // Update cache
    _repository.updateBeerCount(
      id,
      state.value?.firstWhere((b) => b.id == id).count ?? 0,
    );
  }

  /// Decrement beer count (optimistic update)
  void decrementBeer(int id) {
    state = state.whenData((beers) {
      return [
        for (final beer in beers)
          if (beer.id == id && beer.count > 0)
            beer.copyWith(count: beer.count - 1)
          else
            beer,
      ];
    });

    // Update cache
    _repository.updateBeerCount(
      id,
      state.value?.firstWhere((b) => b.id == id).count ?? 0,
    );
  }
}
