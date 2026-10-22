import 'package:customerapp/features/catalog/data/mappers/catalog_api_mapper.dart';
import 'package:customerapp/features/catalog/data/models/api_catalog_product.dart';
import 'package:customerapp/features/catalog/domain/models/catalog_models.dart';
import 'package:customerapp/core/network/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps API catalog item to pipe variant with stock and pricing', () {
    const item = ApiCatalogProduct(
      id: 'cat-1',
      name: 'PIPE SDR-11',
      category: 'Pipes & Tubing',
      unit: 'pcs',
      standardRate: 294,
      productCode: 'M511130301',
      productName: 'PIPE SDR-11',
      type: 'CPVC',
      productGroup: 'PIPE SDR-11',
      brand: 'Astral',
      mrp: 294,
      sellingPrice: 294,
      stock: 5,
      imageUrl: 'https://example.com/pipe.jpg',
      isActive: true,
    );

    final variant = CatalogApiMapper.toVariants([item]).single;
    expect(variant.subCategoryName, 'CPVC');
    expect(variant.brandName, 'Astral');
    expect(variant.inStock, isTrue);
    expect(variant.imageUrl, 'https://example.com/pipe.jpg');
    expect(variant.pipeType, 'PIPE SDR-11');
  });

  test('maps relative snake-case server image paths to absolute URLs', () {
    final item = ApiCatalogProduct.fromJson({
      'id': 'cat-image',
      'name': 'PVC Pipe',
      'category': 'Pipes & Tubing',
      'unit': 'pcs',
      'standardRate': 100,
      'image_url': '/uploads/pvc-pipe.jpg',
    });

    final variant = CatalogApiMapper.toVariants([item]).single;
    expect(
      variant.imageUrl,
      Uri.parse(ApiConfig.baseUrl).resolve('/uploads/pvc-pipe.jpg').toString(),
    );
  });

  test('maps discount percent and fraction from API', () {
    final percentItem = CatalogApiMapper.toVariants([
      const ApiCatalogProduct(
        id: 'cat-3',
        name: 'Pipe A',
        category: 'Pipes & Tubing',
        unit: 'pcs',
        standardRate: 100,
        mrp: 200,
        sellingPrice: 180,
        discount: 10,
        isActive: true,
      ),
    ]).single;
    expect(percentItem.effectiveDiscountRate, 0.1);

    final fractionItem = CatalogApiMapper.toVariants([
      const ApiCatalogProduct(
        id: 'cat-4',
        name: 'Pipe B',
        category: 'Pipes & Tubing',
        unit: 'pcs',
        standardRate: 100,
        mrp: 250,
        sellingPrice: 225,
        discount: 0.1,
        isActive: true,
      ),
    ]).single;
    expect(fractionItem.effectiveDiscountRate, closeTo(0.1, 0.001));
  });

  test('zero stock from API is still purchasable when inventory is not tracked',
      () {
    const item = ApiCatalogProduct(
      id: 'cat-zero-stock',
      name: 'CPVC Pipe',
      category: 'Pipes & Tubing',
      unit: 'Nos',
      standardRate: 265,
      sellingPrice: 265,
      stock: 0,
      isActive: true,
    );

    final variant = CatalogApiMapper.toVariants([item]).single;
    expect(variant.inStock, isTrue);
    expect(CatalogApiMapper.stockStatusFromQuantity(0), StockStatus.inStock);
  });

  test('uses MRP when API sends sellingPrice 0', () {
    final item = ApiCatalogProduct.fromJson({
      'id': 'sku-1',
      'name': 'UPVC Pipe',
      'category': 'PIPES & FITTING',
      'unit': 'Nos',
      'mrp': 486,
      'sellingPrice': 0,
      'discount': 49,
      'standardRate': 0,
    });

    final tree = CatalogApiMapper.toPipesFittingCatalog([item]);
    final product = tree.types.first.subCategories.first.classes.first.products.first;
    expect(product.displayPrice, 486);
  });

  test('inactive API items are excluded', () {
    const item = ApiCatalogProduct(
      id: 'cat-2',
      name: 'Hidden',
      category: 'Pipes & Tubing',
      unit: 'pcs',
      standardRate: 10,
      isActive: false,
    );

    expect(CatalogApiMapper.toVariants([item]), isEmpty);
  });

  test('materialImagesFromCatalogTree maps UPVC CPVC PVC type imageUrl', () {
    final map = CatalogApiMapper.materialImagesFromCatalogTree({
      'data': {
        'categories': [
          {
            'name': 'PIPES & FITTING',
            'types': [
              {'name': 'UPVC', 'imageUrl': 'https://cdn.example/upvc.png'},
              {'name': 'PVC', 'imageUrl': 'https://cdn.example/pvc.png'},
              {'name': 'CPVC', 'imageUrl': 'https://cdn.example/cpvc.png'},
            ],
          },
        ],
      },
    });

    expect(map['UPVC'], 'https://cdn.example/upvc.png');
    expect(map['PVC'], 'https://cdn.example/pvc.png');
    expect(map['CPVC'], 'https://cdn.example/cpvc.png');
  });
}
