import 'dart:convert';
import 'dart:io';

import 'package:customerapp/features/catalog/data/mappers/catalog_api_mapper.dart';
import 'package:customerapp/features/catalog/data/models/api_catalog_product.dart';

void main() {
  final raw = File('catalog_sample.json').readAsStringSync();
  final decoded = jsonDecode(raw);
  final List data = decoded is Map && decoded['data'] is List
      ? decoded['data'] as List
      : decoded as List;

  final items = data
      .whereType<Map<String, dynamic>>()
      .map(ApiCatalogProduct.fromJson)
      .toList();

  final pipeItems = CatalogApiMapper.filterPipeItems(items);
  final upvcPipe = pipeItems.where((i) {
    final type = (i.type ?? '').toUpperCase();
    final sub = CatalogApiMapper.resolveSubCategory(i).toLowerCase();
    return type == 'UPVC' && sub == 'pipe';
  }).toList();

  stdout.writeln('UPVC Pipe SKUs: ${upvcPipe.length}');

  double displayPrice(ApiCatalogProduct item) {
    final mrp = item.resolvedMrp;
    final selling = item.resolvedSelling;
    if (selling > 0) return selling;
    if (mrp > 0) return mrp;
    return 0;
  }

  final zero = upvcPipe.where((i) => displayPrice(i) <= 0).length;
  final pos = upvcPipe.length - zero;
  stdout.writeln('With price: $pos, zero: $zero');

  if (upvcPipe.isNotEmpty) {
    final sample = upvcPipe.firstWhere(
      (i) => displayPrice(i) > 0,
      orElse: () => upvcPipe.first,
    );
    stdout.writeln(
      'Sample: ${sample.productName} mrp=${sample.mrp} sp=${sample.sellingPrice} sr=${sample.standardRate} resolved=${displayPrice(sample)}',
    );
  }

  // Rough family bucket by normalized name without sch
  final buckets = <String, List<ApiCatalogProduct>>{};
  for (final item in upvcPipe) {
    var name = (item.productGroup ?? item.productName ?? item.name).toLowerCase();
    name = name.replaceAll(RegExp(r'sch\s*\d+'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    buckets.putIfAbsent(name, () => []).add(item);
  }
  final top = buckets.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));
  for (final e in top.take(3)) {
    final prices = e.value.map(displayPrice).where((p) => p > 0);
    final min = prices.isEmpty ? 0.0 : prices.reduce((a, b) => a < b ? a : b);
    final z = e.value.where((i) => displayPrice(i) <= 0).length;
    stdout.writeln('${e.value.length} skus min=$min zeros=$z key=${e.key.substring(0, e.key.length.clamp(0, 60))}');
  }
}
