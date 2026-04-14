// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameHistoryModelAdapter extends TypeAdapter<GameHistoryModel> {
  @override
  final int typeId = 2;

  @override
  GameHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameHistoryModel(
      word: fields[0] as String,
      mode: fields[1] as String,
      won: fields[2] as bool,
      attemptsUsed: fields[3] as int,
      playedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GameHistoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.mode)
      ..writeByte(2)
      ..write(obj.won)
      ..writeByte(3)
      ..write(obj.attemptsUsed)
      ..writeByte(4)
      ..write(obj.playedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
