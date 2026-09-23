/// Domain models for the "Pipes & Fitting" mock catalog
/// (assets/data/pipes_fitting_mock_data.json).
///
/// Hierarchy: Category -> Type (UPVC/CPVC/PVC) -> SubCategory -> Class -> Product.
class PipesFittingProduct {
  const PipesFittingProduct({
    required this.brand,
    required this.productName,
    this.length,
    this.size,
    this.productCode,
    this.stdPkg,
    required this.mrp,
    this.sellingPrice,
    this.discountPercent,
    this.stock,
    this.imageUrl,
  });

  final String brand;
  final String productName;
  final String? length;
  final String? size;
  final String? productCode;
  final String? stdPkg;
  final double mrp;
  final double? sellingPrice;
  final double? discountPercent;
  final double? stock;
  final String? imageUrl;

  /// Price the customer pays. Falls back to MRP when selling price is absent.
  double get displayPrice {
    final selling = sellingPrice;
    if (selling != null && selling > 0) return selling;
    return mrp;
  }

  factory PipesFittingProduct.fromJson(Map<String, dynamic> json) {
    return PipesFittingProduct(
      brand: json['brand']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      length: json['length']?.toString(),
      size: json['size']?.toString(),
      productCode: json['productCode']?.toString(),
      stdPkg: json['stdPkg']?.toString(),
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PipesFittingClass {
  const PipesFittingClass({
    required this.className,
    required this.products,
  });

  final String className;
  final List<PipesFittingProduct> products;

  factory PipesFittingClass.fromJson(Map<String, dynamic> json) {
    return PipesFittingClass(
      className: json['class']?.toString() ?? '',
      products: (json['products'] as List<dynamic>? ?? [])
          .map((e) => PipesFittingProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PipesFittingSubCategory {
  const PipesFittingSubCategory({
    required this.subCategory,
    required this.classes,
  });

  final String subCategory;
  final List<PipesFittingClass> classes;

  factory PipesFittingSubCategory.fromJson(Map<String, dynamic> json) {
    return PipesFittingSubCategory(
      subCategory: json['subCategory']?.toString() ?? '',
      classes: (json['classes'] as List<dynamic>? ?? [])
          .map((e) => PipesFittingClass.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get productCount =>
      classes.fold(0, (sum, c) => sum + c.products.length);
}

class PipesFittingType {
  const PipesFittingType({
    required this.type,
    required this.subCategories,
  });

  final String type;
  final List<PipesFittingSubCategory> subCategories;

  factory PipesFittingType.fromJson(Map<String, dynamic> json) {
    return PipesFittingType(
      type: json['type']?.toString() ?? '',
      subCategories: (json['subCategories'] as List<dynamic>? ?? [])
          .map(
            (e) => PipesFittingSubCategory.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  int get productCount =>
      subCategories.fold(0, (sum, s) => sum + s.productCount);
}

class PipesFittingCatalog {
  const PipesFittingCatalog({
    required this.category,
    required this.types,
  });

  final String category;
  final List<PipesFittingType> types;

  factory PipesFittingCatalog.fromJson(Map<String, dynamic> json) {
    return PipesFittingCatalog(
      category: json['category']?.toString() ?? '',
      types: (json['types'] as List<dynamic>? ?? [])
          .map((e) => PipesFittingType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  PipesFittingType? typeByName(String name) {
    for (final type in types) {
      if (type.type == name) return type;
    }
    return null;
  }
}
