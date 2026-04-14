// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_stats_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerStatsModelAdapter extends TypeAdapter<PlayerStatsModel> {
  @override
  final int typeId = 1;

  @override
  PlayerStatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerStatsModel(
      gamesPlayed: fields[0] as int,
      gamesWon: fields[1] as int,
      currentStreak: fields[2] as int,
      bestStreak: fields[3] as int,
      guessDistribution: (fields[4] as Map?)?.cast<int, int>(),
      rageModeLives: fields[5] as int,
      totalRageRuns: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerStatsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.gamesPlayed)
      ..writeByte(1)
      ..write(obj.gamesWon)
      ..writeByte(2)
      ..write(obj.currentStreak)
      ..writeByte(3)
      ..write(obj.bestStreak)
      ..writeByte(4)
      ..write(obj.guessDistribution)
      ..writeByte(5)
      ..write(obj.rageModeLives)
      ..writeByte(6)
      ..write(obj.totalRageRuns);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStatsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
