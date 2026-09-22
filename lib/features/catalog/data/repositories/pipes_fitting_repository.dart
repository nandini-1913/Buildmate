import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/pipes_fitting_catalog_models.dart';

/// Loads the "Pipes & Fitting" mock catalog from
/// assets/data/pipes_fitting_mock_data.json.
abstract final class PipesFittingRepository {
  static const String _assetPath = 'assets/data/pipes_fitting_mock_data.json';

  static PipesFittingCatalog? _cache;

  static Future<PipesFittingCatalog> load() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final catalog = PipesFittingCatalog.fromJson(json);
    _cache = catalog;
    return catalog;
  }
}
