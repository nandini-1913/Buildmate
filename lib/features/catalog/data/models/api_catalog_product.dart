/// Raw catalog item from `GET /api/catalog` (dashboard backend schema).
class ApiCatalogProduct {
  const ApiCatalogProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.standardRate,
    this.productCode,
    this.productName,
    this.type,
    this.productGroup,
    this.productClass,
    this.subcategory,
    this.size,
    this.brand,
    this.brandId,
    this.sizeMm,
    this.sizeInch,
    this.length,
    this.mrp,
    this.sellingPrice,
    this.discount,
    this.stock,
    this.imageUrl,
    this.isActive = true,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String category;
  final String unit;
  final double standardRate;
  final String? productCode;
  final String? productName;
  final String? type;
  final String? productGroup;
  final String? productClass;
  final String? subcategory;
  final String? size;
  final String? brand;
  final String? brandId;
  final double? sizeMm;
  final String? sizeInch;
  final String? length;
  final double? mrp;
  final double? sellingPrice;
  final double? discount;
  final double? stock;
  final String? imageUrl;
  final bool isActive;
  final String? updatedAt;

  factory ApiCatalogProduct.fromJson(Map<String, dynamic> json) {
    return ApiCatalogProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      unit: json['unit']?.toString() ?? 'pcs',
      standardRate: _toDouble(json['standardRate']) ?? 0,
      productCode: _nullableString(json['productCode']),
      productName: _nullableString(json['productName']),
      type: _nullableString(json['type']),
      productGroup: _nullableString(json['productGroup']),
      productClass: _nullableString(json['productClass']),
      subcategory: _nullableString(json['subcategory']),
      size: _nullableString(json['size']),
      brand: _nullableString(json['brand']),
      brandId: _nullableString(json['brandId']),
      sizeMm: _toDouble(json['sizeMm']),
      sizeInch: _nullableString(json['sizeInch']),
      length: _nullableString(json['length']),
      mrp: _toDouble(json['mrp']),
      sellingPrice: _toDouble(json['sellingPrice']),
      discount: _toDouble(json['discount']),
      stock: _toDouble(json['stock']),
      imageUrl: _nullableString(json['imageUrl']),
      isActive: json['isActive'] != false,
      updatedAt: _nullableString(json['updatedAt']),
    );
  }

  /// Stable fingerprint for polling change detection.
  String get syncFingerprint => [
        id,
        productCode ?? '',
        name,
        category,
        type ?? '',
        productGroup ?? '',
        productClass ?? '',
        subcategory ?? '',
        size ?? '',
        brand ?? '',
        sizeMm?.toString() ?? '',
        mrp?.toString() ?? '',
        sellingPrice?.toString() ?? '',
        discount?.toString() ?? '',
        stock?.toString() ?? '',
        imageUrl ?? '',
        isActive.toString(),
        updatedAt ?? '',
      ].join('|');

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString().replaceAll(',', '').trim());
    return parsed;
  }
}
