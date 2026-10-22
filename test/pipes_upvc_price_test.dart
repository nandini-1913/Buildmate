import 'dart:convert';
import 'dart:io';

import 'package:customerapp/features/catalog/data/mappers/catalog_api_mapper.dart';
import 'package:customerapp/features/catalog/data/models/api_catalog_product.dart';
import 'package:customerapp/features/catalog/presentation/screens/pipes_fitting_category_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UPVC pipe rows from live catalog have positive displayPrice', () {
    final path = File('catalog_sample.json');
    expect(path.existsSync(), isTrue, reason: 'Run tool/analyze_catalog.dart first');

    final decoded = jsonDecode(path.readAsStringSync());
    final List data = decoded is Map && decoded['data'] is List
        ? decoded['data'] as List
        : decoded as List;

    final items = data
        .whereType<Map<String, dynamic>>()
        .map(ApiCatalogProduct.fromJson)
        .toList();
    final pipeItems = CatalogApiMapper.filterPipeItems(items);
    final upvcPipe = pipeItems.where((i) {
      return i.type?.toUpperCase() == 'UPVC' &&
          CatalogApiMapper.resolveSubCategory(i) == 'Pipe';
    }).toList();

    expect(upvcPipe.length, 96);

    final tree = CatalogApiMapper.toPipesFittingCatalog(pipeItems);
    final allProducts = tree.types
        .expand((t) => t.subCategories)
        .expand((s) => s.classes)
        .expand((c) => c.products)
        .where((p) => upvcPipe.any((i) => i.id == p.id))
        .toList();

    expect(allProducts.length, upvcPipe.length);

    final priced = allProducts.where((p) => p.displayPrice > 0).length;
    expect(priced, greaterThan(80));

    final min = allProducts
        .map((p) => p.displayPrice)
        .where((p) => p > 0)
        .reduce((a, b) => a < b ? a : b);
    expect(min, greaterThan(0));

    final groups = buildPipeCatalogGroupsForSection(tree, 'UPVC', 'Pipe');
    final merged = groups.reduce(
      (a, b) => a.products.length >= b.products.length ? a : b,
    );
    expect(merged.products.length, 96);
    expect(merged.minMrp, greaterThan(0));

    final classOptions = pipeClassFilterOptionsForCatalog(tree, 'UPVC');
    expect(classOptions, contains('Sch 40'));
    expect(classOptions, contains('Sch 80'));

    final familyClasses = pipeClassOptionsForFamily(
      [merged],
      typeName: 'UPVC',
    );
    expect(familyClasses.length, 2);
    expect(familyClasses, containsAll(['Sch 40', 'Sch 80']));
  });
}
