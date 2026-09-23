import 'dart:async';

import 'package:flutter/foundation.dart';

import '../network/api_config.dart';
import '../../features/catalog/data/mappers/catalog_api_mapper.dart';
import '../../features/catalog/data/mock/catalog_mock_data.dart';
import '../../features/catalog/data/repositories/catalog_repository.dart';
import '../../features/catalog/domain/models/catalog_models.dart';
import '../../features/catalog/domain/models/pipes_fitting_catalog_models.dart';

/// API-backed catalog state with safe polling for the Pipes & Tubing demo.
///
/// Falls back to [CatalogMockData] when the API is unavailable on first load.
class CatalogController extends ChangeNotifier {
  CatalogController({CatalogRepository? repository})
      : _repository = repository ?? CatalogRepository();

  final CatalogRepository _repository;

  Timer? _pollTimer;
  bool _disposed = false;
  bool _isLoading = false;
  bool _isPolling = false;
  bool _refreshInFlight = false;
  String? _error;
  bool _useApi = false;
  List<ProductVariant> _apiVariants = const [];
  PipesFittingCatalog? _pipesCatalog;
  String _apiSyncToken = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUsingApi => _useApi;
  bool get isPolling => _isPolling;
  PipesFittingCatalog? get pipesFittingCatalog => _pipesCatalog;

  /// Latest copy of a SKU so open product screens pick up polled price/stock.
  PipesFittingProduct? productByCode(String? productCode) {
    final code = productCode?.trim();
    final catalog = _pipesCatalog;
    if (code == null || code.isEmpty || catalog == null) return null;
    for (final type in catalog.types) {
      for (final sub in type.subCategories) {
        for (final cls in sub.classes) {
          for (final product in cls.products) {
            if (product.productCode == code) return product;
          }
        }
      }
    }
    return null;
  }

  /// Changes when API catalog content changes — use to reset UI filters.
  String get pipeCatalogFingerprint => _apiSyncToken;

  List<ProductVariant> get pipeVariants {
    if (_useApi && _apiVariants.isNotEmpty) return _apiVariants;
    return CatalogMockData.variants
        .where((v) => CatalogMockData.plumbingModuleCategoryIds
            .contains(v.categoryId))
        .toList();
  }

  List<ProductVariant> pipeVariantsForSubCategory(String? subCategoryId) {
    final all = pipeVariants;
    if (subCategoryId == null) return all;
    return all.where((v) => v.subCategoryId == subCategoryId).toList();
  }

  Brand? brandById(String brandId) {
    final fromApi = _brandsFromVariants()
        .where((b) => b.id == brandId)
        .firstOrNull;
    if (fromApi != null) return fromApi;
    return CatalogMockData.brandById(brandId);
  }

  List<Brand> brandsForPipeCategory() {
    if (_useApi && _apiVariants.isNotEmpty) {
      return _brandsFromVariants();
    }
    final seen = <String>{};
    final result = <Brand>[];
    for (final categoryId in CatalogMockData.plumbingModuleCategoryIds) {
      for (final brand in CatalogMockData.brandsForCategory(categoryId)) {
        if (seen.add(brand.id)) result.add(brand);
      }
    }
    return result;
  }

  /// Initial load + starts 3-second polling (idempotent).
  Future<void> startPipeCatalogSync() async {
    if (_isPolling) return;
    _isPolling = true;
    await refreshPipeCatalog(showLoading: _apiVariants.isEmpty);
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      ApiConfig.catalogPollInterval,
      (_) => refreshPipeCatalog(showLoading: false),
    );
  }

  void stopPipeCatalogSync() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isPolling = false;
  }

  Future<void> refreshPipeCatalog({bool showLoading = false}) async {
    if (_disposed || _refreshInFlight) return;
    _refreshInFlight = true;
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final items = await _repository.fetchPipeCatalog();
      if (_disposed) return;

      final nextVariants = CatalogApiMapper.toVariants(items);
      final nextCatalog = CatalogApiMapper.toPipesFittingCatalog(items);
      final nextToken = items.map((item) => item.syncFingerprint).join('||');

      if (nextToken != _apiSyncToken) {
        _apiSyncToken = nextToken;
        _apiVariants = nextVariants;
        _pipesCatalog = nextCatalog.types.isEmpty ? null : nextCatalog;
        _useApi = nextVariants.isNotEmpty || _pipesCatalog != null;
        _error = null;
        notifyListeners();
      } else if (_useApi) {
        _error = null;
      }
    } catch (e) {
      if (_disposed) return;
      _error = e.toString();
      if (_apiVariants.isEmpty && _pipesCatalog == null) {
        _useApi = false;
        notifyListeners();
      }
    } finally {
      _refreshInFlight = false;
      if (!_disposed && showLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  List<Brand> _brandsFromVariants() {
    final map = <String, Brand>{};
    for (final variant in _apiVariants) {
      map.putIfAbsent(
        variant.brandId,
        () => Brand(
          id: variant.brandId,
          name: variant.brandName,
          abbreviation: _abbreviation(variant.brandName),
          color: 0xFF1565C0,
          productCount: 0,
        ),
      );
    }
    final brands = map.values.toList();
    for (final brand in brands) {
      final count =
          _apiVariants.where((v) => v.brandId == brand.id).length;
      map[brand.id] = Brand(
        id: brand.id,
        name: brand.name,
        abbreviation: brand.abbreviation,
        color: brand.color,
        productCount: count,
      );
    }
    return map.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  String _abbreviation(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  void dispose() {
    _disposed = true;
    stopPipeCatalogSync();
    _repository.dispose();
    super.dispose();
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
