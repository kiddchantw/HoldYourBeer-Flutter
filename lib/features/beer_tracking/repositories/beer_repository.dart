import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/date_time_utils.dart';
import '../models/beer_item.dart';

/// Tasting log model for beer consumption records
class TastingLog {
  final int id;
  final String action;
  final DateTime tastedAt;
  final String? note;

  TastingLog({
    required this.id,
    required this.action,
    required this.tastedAt,
    this.note,
  });

  factory TastingLog.fromJson(Map<String, dynamic> json) {
    return TastingLog(
      id: json['id'] as int,
      action: json['action'] as String,
      tastedAt: DateTimeUtils.parseServerDateTimeWithTimezone(
        json['tasted_at'] as String,
        json['server_timezone'] as String?,
      ),
      note: json['note'] as String?,
    );
  }
}

/// Repository for managing beer data with local caching
///
/// Implements cache-aside pattern:
/// 1. Try to read from cache first
/// 2. If cache miss or force refresh, fetch from API
/// 3. Update cache with fresh data
/// 4. On API failure, return cached data if available
class BeerRepository {
  final ApiClient _apiClient = ApiClient();
  final String _boxName = 'beer_data';

  /// Get Hive box for beer data
  Box<BeerItem> get _beerBox => Hive.box<BeerItem>(_boxName);

  /// Fetch beers with caching strategy
  ///
  /// [forceRefresh] - Skip cache and fetch from API
  /// Returns list of beers from cache or API
  Future<List<BeerItem>> getBeers({bool forceRefresh = false}) async {
    try {
      // 1. Try to get from cache first (if not forcing refresh)
      if (!forceRefresh && _beerBox.isNotEmpty) {
        logger.d('Returning ${_beerBox.length} beers from cache');
        return _beerBox.values.toList();
      }

      // 2. Fetch from API
      logger.i('Fetching beers from API');
      final response = await _apiClient.dio.get('/beers');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        final beers = data
            .map((json) => BeerItem.fromJson(json as Map<String, dynamic>))
            .toList();

        // 3. Update cache
        await _updateCache(beers);
        logger.i('Successfully fetched and cached ${beers.length} beers');
        return beers;
      } else {
        throw Exception('Failed to load beers: ${response.statusCode}');
      }
    } on DioException catch (e, stack) {
      logger.e('API error while fetching beers', error: e, stackTrace: stack);

      // 4. On API failure, return cached data if available
      if (_beerBox.isNotEmpty) {
        logger.w('Returning ${_beerBox.length} beers from cache (API failed)');
        return _beerBox.values.toList();
      }

      rethrow;
    } catch (e, stack) {
      logger.e('Unexpected error in getBeers', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Create a new beer
  ///
  /// Returns the created beer with server-assigned ID
  Future<BeerItem> createBeer({
    required String brand,
    required String name,
    String? style,
  }) async {
    try {
      logger.i('Creating new beer: $brand - $name');

      final response = await _apiClient.dio.post(
        '/beers',
        data: {
          'brand': brand,
          'name': name,
          if (style != null && style.isNotEmpty) 'style': style,
          'tasting_count': 1,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final beerData = response.data['data'] as Map<String, dynamic>;
        final newBeer = BeerItem.fromJson(beerData);

        // Add to cache
        await _beerBox.put(newBeer.id, newBeer);
        logger.i('Successfully created and cached beer ID: ${newBeer.id}');

        return newBeer;
      } else {
        throw Exception('Failed to create beer: ${response.statusCode}');
      }
    } on DioException catch (e, stack) {
      logger.e('API error while creating beer', error: e, stackTrace: stack);
      rethrow;
    } catch (e, stack) {
      logger.e('Unexpected error in createBeer', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Update beer count (increment/decrement)
  Future<BeerItem> updateBeerCount(int beerId, int newCount) async {
    try {
      logger.d('Updating beer $beerId count to $newCount');

      // Update cache optimistically
      final cachedBeer = _beerBox.get(beerId);
      if (cachedBeer != null) {
        final updatedBeer = cachedBeer.copyWith(count: newCount);
        await _beerBox.put(beerId, updatedBeer);
      }

      // Note: Count updates are done via count_actions endpoint
      // This method is for local cache updates
      final beer = _beerBox.get(beerId);
      if (beer != null) {
        return beer;
      } else {
        throw Exception('Beer not found in cache');
      }
    } catch (e, stack) {
      logger.e('Error updating beer count', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Update cache with fresh data from API
  Future<void> _updateCache(List<BeerItem> beers) async {
    try {
      // Clear old cache
      await _beerBox.clear();

      // Store new data
      final Map<int, BeerItem> beerMap = {
        for (var beer in beers) beer.id: beer,
      };
      await _beerBox.putAll(beerMap);

      logger.d('Cache updated with ${beers.length} beers');
    } catch (e, stack) {
      logger.e('Error updating cache', error: e, stackTrace: stack);
      // Don't rethrow - caching failure shouldn't break the app
    }
  }

  /// Clear all cached beers
  Future<void> clearCache() async {
    try {
      await _beerBox.clear();
      logger.i('Beer cache cleared');
    } catch (e, stack) {
      logger.e('Error clearing cache', error: e, stackTrace: stack);
    }
  }

  /// Get cached beer count
  int getCachedBeerCount() {
    return _beerBox.length;
  }

  // ============================================================================
  // Tasting Logs & Count Actions
  // ============================================================================

  /// Get tasting logs for a specific beer
  Future<List<TastingLog>> getTastingLogs(int beerId) async {
    try {
      logger.i('Fetching tasting logs for beer $beerId');
      final response = await _apiClient.dio.get('/beers/$beerId/tasting_logs');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final logs = data
            .map((json) => TastingLog.fromJson(json as Map<String, dynamic>))
            .toList();
        logger.i('Successfully fetched ${logs.length} tasting logs');
        return logs;
      } else {
        throw Exception('Failed to load tasting logs: ${response.statusCode}');
      }
    } on DioException catch (e, stack) {
      logger.e('API error while fetching tasting logs', error: e, stackTrace: stack);
      rethrow;
    } catch (e, stack) {
      logger.e('Unexpected error in getTastingLogs', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Add a tasting record with optional note
  Future<void> addTastingRecord(int beerId, String note) async {
    try {
      logger.i('Adding tasting record for beer $beerId with note');
      await _apiClient.dio.post(
        '/beers/$beerId/count_actions',
        data: {
          'action': 'increment',
          if (note.isNotEmpty) 'note': note,
        },
      );
      logger.i('Successfully added tasting record');
    } on DioException catch (e, stack) {
      logger.e('Error adding tasting record', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Increment beer count
  Future<void> incrementBeerCount(int beerId) async {
    try {
      logger.d('Incrementing beer $beerId count');
      await _apiClient.dio.post(
        '/beers/$beerId/count_actions',
        data: {'action': 'increment'},
      );

      // Update cache optimistically
      final beer = _beerBox.get(beerId);
      if (beer != null) {
        await _beerBox.put(beerId, beer.copyWith(count: beer.count + 1));
      }
    } on DioException catch (e, stack) {
      logger.e('Error incrementing beer count', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Decrement beer count
  Future<void> decrementBeerCount(int beerId) async {
    try {
      logger.d('Decrementing beer $beerId count');
      await _apiClient.dio.post(
        '/beers/$beerId/count_actions',
        data: {'action': 'decrement'},
      );

      // Update cache optimistically
      final beer = _beerBox.get(beerId);
      if (beer != null && beer.count > 0) {
        await _beerBox.put(beerId, beer.copyWith(count: beer.count - 1));
      }
    } on DioException catch (e, stack) {
      logger.e('Error decrementing beer count', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
