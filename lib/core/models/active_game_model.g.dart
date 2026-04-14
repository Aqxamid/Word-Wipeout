// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_game_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActiveGameModelAdapter extends TypeAdapter<ActiveGameModel> {
  @override
  final int typeId = 4;

  @override
  ActiveGameModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActiveGameModel(
      targetWord: fields[0] as String,
      guesses: (fields[1] as List).cast<String>(),
      currentInput: fields[2] as String,
      gameMode: fields[3] as String,
      maxAttempts: fields[4] as int,
      rageLives: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ActiveGameModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.targetWord)
      ..writeByte(1)
      ..write(obj.guesses)
      ..writeByte(2)
      ..write(obj.currentInput)
      ..writeByte(3)
      ..write(obj.gameMode)
      ..writeByte(4)
      ..write(obj.maxAttempts)
      ..writeByte(5)
      ..write(obj.rageLives);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveGameModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
