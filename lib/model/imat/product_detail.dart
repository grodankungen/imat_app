class ProductDetail {
  int productId;
  String brand;
  String description;
  String contents;
  String origin;

  ProductDetail(
    this.productId,
    this.brand,
    this.description,
    this.contents,
    this.origin,
  );

  ProductDetail.fromJson(Map<String, dynamic> json)
    : productId = json[_idKey],
      brand = json[_brandKey],
      description = json[_descKey],
      contents = json[_contentsKey],
      origin = json[_originKey];

  static const _idKey = 'productId';
  static const _brandKey = 'brand';
  static const _descKey = 'description';
  static const _contentsKey = 'contents';
  static const _originKey = 'origin';
}
