// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceData _$PriceDataFromJson(Map<String, dynamic> json) => PriceData(
      productName: json['productName'] as String,
      averagePrice: (json['averagePrice'] as num).toDouble(),
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      stores: (json['stores'] as List<dynamic>)
          .map((e) => StorePrice.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => PriceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$PriceDataToJson(PriceData instance) => <String, dynamic>{
      'productName': instance.productName,
      'averagePrice': instance.averagePrice,
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'stores': instance.stores.map((e) => e.toJson()).toList(),
      'items': instance.items?.map((e) => e.toJson()).toList(),
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

StorePrice _$StorePriceFromJson(Map<String, dynamic> json) => StorePrice(
      storeName: json['storeName'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$StorePriceToJson(StorePrice instance) =>
    <String, dynamic>{
      'storeName': instance.storeName,
      'price': instance.price,
    };

PriceItem _$PriceItemFromJson(Map<String, dynamic> json) => PriceItem(
      code: json['code'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      manufacturer: json['manufacturer'] as String?,
    );

Map<String, dynamic> _$PriceItemToJson(PriceItem instance) => <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'price': instance.price,
      'manufacturer': instance.manufacturer,
    };
