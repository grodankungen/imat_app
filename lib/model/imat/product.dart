// ignore_for_file: constant_identifier_names

enum ProductCategory {
  POD,
  BREAD,
  BERRY,
  CITRUS_FRUIT,
  HOT_DRINKS,
  COLD_DRINKS,
  EXOTIC_FRUIT,
  FISH,
  VEGETABLE_FRUIT,
  CABBAGE,
  MEAT,
  DAIRIES,
  MELONS,
  FLOUR_SUGAR_SALT,
  NUTS_AND_SEEDS,
  PASTA,
  POTATO_RICE,
  ROOT_VEGETABLE,
  FRUIT,
  SWEET,
  HERB,
  UNDEFINED,
}

class Product {
  int productId;
  ProductCategory category;
  String name;
  bool isEcological;
  double price;
  String unit;
  String imageName;

  Product(
    this.productId,
    this.category,
    this.name,
    this.isEcological,
    this.price,
    this.unit,
    this.imageName,
  );

  Product.fromJson(Map<String, dynamic> json)
    : productId = json[_idKey],
      category = _category(json[_catKey]),
      name = json[_nameKey],
      isEcological = json[_ecoKey],
      price = json[_priceKey],
      unit = json[_unitKey],
      imageName = json[_imageKey];

  Map<String, dynamic> toJson() => {
    _idKey: productId,
    _catKey: category.name,
    _nameKey: name,
    'isEcological': isEcological, // Fix to be able to match Jav class on server
    _priceKey: price,
    _unitKey: unit,
    _imageKey: imageName,
  };

  static const _idKey = 'productId';
  static const _catKey = 'category';
  static const _nameKey = 'name';
  static const _ecoKey = 'ecological';
  static const _priceKey = 'price';
  static const _unitKey = 'unit';
  static const _imageKey = 'imageName';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    final Product otherProduct = other as Product;
    return productId == otherProduct.productId;
  }

  @override
  int get hashCode => productId.hashCode;
}

ProductCategory _category(String cat) {
  switch (cat) {
    case 'POD':
      return ProductCategory.POD;
    case 'BREAD':
      return ProductCategory.BREAD;
    case 'BERRY':
      return ProductCategory.BERRY;
    case 'CITRUS_FRUIT':
      return ProductCategory.CITRUS_FRUIT;
    case 'HOT_DRINKS':
      return ProductCategory.HOT_DRINKS;
    case 'COLD_DRINKS':
      return ProductCategory.COLD_DRINKS;
    case 'EXOTIC_FRUIT':
      return ProductCategory.EXOTIC_FRUIT;
    case 'FISH':
      return ProductCategory.FISH;
    case 'VEGETABLE_FRUIT':
      return ProductCategory.VEGETABLE_FRUIT;
    case 'CABBAGE':
      return ProductCategory.CABBAGE;
    case 'MEAT':
      return ProductCategory.MEAT;
    case 'DAIRIES':
      return ProductCategory.DAIRIES;
    case 'MELONS':
      return ProductCategory.MELONS;
    case 'FLOUR_SUGAR_SALT':
      return ProductCategory.FLOUR_SUGAR_SALT;
    case 'NUTS_AND_SEEDS':
      return ProductCategory.NUTS_AND_SEEDS;
    case 'PASTA':
      return ProductCategory.PASTA;
    case 'POTATO_RICE':
      return ProductCategory.POTATO_RICE;
    case 'ROOT_VEGETABLE':
      return ProductCategory.ROOT_VEGETABLE;
    case 'FRUIT':
      return ProductCategory.FRUIT;
    case 'SWEET':
      return ProductCategory.SWEET;
    case 'HERB':
      return ProductCategory.HERB;
  }
  return ProductCategory.UNDEFINED;
}
