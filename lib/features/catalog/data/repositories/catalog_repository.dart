import 'package:flutter/foundation.dart' hide Category;

import '../../../../core/network/api_client.dart';
import '../../domain/models/catalog_models.dart';
import '../mappers/catalog_api_mapper.dart';
import '../models/api_catalog_product.dart';
import '../models/api_subcategory.dart';

class CatalogRepository {
  CatalogRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Fetches active categories from `GET /api/categories`.
  Future<List<Category>> fetchCategories({bool activeOnly = true}) async {
    final envelope = await _apiClient.getJson(
      '/categories',
      queryParameters: {
        if (activeOnly) 'active_only': 'true',
      },
    );

    final data = envelope['data'] ?? envelope['items'] ?? envelope;
    if (data is! List) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(CatalogApiMapper.categoryFromJson)
        .where((c) => c.id.isNotEmpty && c.name.isNotEmpty)
        .toList();
  }

  /// Sub-categories for a pipes category (UPVC, CPVC, PVC, …) including `imageUrl`.
  Future<List<ApiSubCategory>> fetchSubcategories({String? categoryId}) async {
    final envelope = await _apiClient.getJson(
      '/subcategories',
      queryParameters: {
        if (categoryId != null && categoryId.isNotEmpty)
          'category_id': categoryId,
      },
    );

    final data = envelope['data'] ?? envelope['items'] ?? envelope;
    if (data is! List) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(ApiSubCategory.fromJson)
        .where((s) => s.id.isNotEmpty && s.name.isNotEmpty)
        .toList();
  }

  /// Fetches active pipe catalog items from the live backend.
  Future<List<ApiCatalogProduct>> fetchPipeCatalog() async {
    Map<String, dynamic>? envelope;
    Object? lastError;

    // Prefer filtered catalog for PIPES & FITTING.
    try {
      envelope = await _apiClient.getJson(
        '/catalog',
        queryParameters: {
          'category': CatalogApiMapper.pipesCategoryQuery,
        },
      );
    } catch (e) {
      lastError = e;
      if (kDebugMode) {
        print('Catalog filtered fetch failed: $e');
      }
    }

    // Fallback: full catalog, then filter client-side.
    if (envelope == null) {
      try {
        envelope = await _apiClient.getJson('/catalog');
      } catch (e) {
        lastError = e;
        if (kDebugMode) {
          print('Catalog full fetch failed: $e');
        }
        throw ApiException(
          'Unable to load catalog from server',
          statusCode: e is ApiException ? e.statusCode : null,
          body: e.toString(),
        );
      }
    }

    final data = envelope['data'] ?? envelope['items'] ?? envelope;
    if (data is! List) {
      throw ApiException(
        lastError?.toString() ?? 'Catalog response was empty',
      );
    }

    final items = data
        .whereType<Map<String, dynamic>>()
        .map(ApiCatalogProduct.fromJson)
        .toList();

    return CatalogApiMapper.filterPipeItems(items);
  }

  /// Sidebar **Type** images (UPVC, CPVC, PVC) from `GET /api/catalog/tree`.
  Future<Map<String, String>> fetchPipeTypeImagesFromTree({
    bool activeOnly = true,
  }) async {
    try {
      final envelope = await _apiClient.getJson(
        '/catalog/tree',
        queryParameters: {
          if (activeOnly) 'active_only': 'true',
        },
      );
      return CatalogApiMapper.materialImagesFromCatalogTree(envelope);
    } catch (e) {
      if (kDebugMode) {
        print('Catalog tree fetch failed: $e');
      }
      return const {};
    }
  }

  void dispose() => _apiClient.dispose();
}
