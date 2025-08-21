// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdAdapter extends TypeAdapter<Ad> {
  @override
  final int typeId = 0;

  @override
  Ad read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ad(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      title: fields[2] as String,
      price: fields[3] as int,
      phoneNumber: fields[4] as String?,
      description: fields[5] as String?,
      imageUrls: (fields[6] as List).cast<String>(),
      model: fields[7] as String,
      storage: fields[8] as int,
      colorAr: fields[9] as String?,
      conditionAr: fields[10] as String?,
      city: fields[11] as String?,
      isRepaired: fields[12] as bool?,
      repairedParts: fields[13] as String?,
      batteryHealth: fields[14] as int?,
      hasBox: fields[15] as bool?,
      hasCharger: fields[16] as bool?,
      userId: fields[17] as String,
      viewCount: fields[18] as int,
      isFeatured: fields[19] as bool,
      featuredUntil: fields[20] as DateTime?,
      whatsappClicks: fields[21] as int,
      callClicks: fields[22] as int,
      bumpedAt: fields[23] as DateTime?,
      status: fields[24] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Ad obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.imageUrls)
      ..writeByte(7)
      ..write(obj.model)
      ..writeByte(8)
      ..write(obj.storage)
      ..writeByte(9)
      ..write(obj.colorAr)
      ..writeByte(10)
      ..write(obj.conditionAr)
      ..writeByte(11)
      ..write(obj.city)
      ..writeByte(12)
      ..write(obj.isRepaired)
      ..writeByte(13)
      ..write(obj.repairedParts)
      ..writeByte(14)
      ..write(obj.batteryHealth)
      ..writeByte(15)
      ..write(obj.hasBox)
      ..writeByte(16)
      ..write(obj.hasCharger)
      ..writeByte(17)
      ..write(obj.userId)
      ..writeByte(18)
      ..write(obj.viewCount)
      ..writeByte(19)
      ..write(obj.isFeatured)
      ..writeByte(20)
      ..write(obj.featuredUntil)
      ..writeByte(21)
      ..write(obj.whatsappClicks)
      ..writeByte(22)
      ..write(obj.callClicks)
      ..writeByte(23)
      ..write(obj.bumpedAt)
      ..writeByte(24)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
