// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductEntityAdapter extends TypeAdapter<ProductEntity> {
  @override
  final int typeId = 0;

  @override
  ProductEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductEntity(
      barcode: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      brand: fields[3] as String,
      unit: fields[4] as String,
      icon: fields[5] as String,
      currentPrice: fields[6] as double?,
      lastPriceStore: fields[7] as String?,
      lastPriceUpdate: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductEntity obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.barcode)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.brand)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.icon)
      ..writeByte(6)
      ..write(obj.currentPrice)
      ..writeByte(7)
      ..write(obj.lastPriceStore)
      ..writeByte(8)
      ..write(obj.lastPriceUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
