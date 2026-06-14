import 'package:equatable/equatable.dart';

/// Tiempo del día sin dependencias de Flutter.
/// Almacenado internamente como minutos desde medianoche.
class MedTime extends Equatable implements Comparable<MedTime> {
  final int hour;
  final int minute;

  const MedTime(this.hour, this.minute)
      : assert(hour >= 0 && hour <= 23),
        assert(minute >= 0 && minute <= 59);

  factory MedTime.fromMinutes(int totalMinutes) {
    final clamped = totalMinutes % (24 * 60);
    return MedTime(clamped ~/ 60, clamped % 60);
  }

  int get totalMinutes => hour * 60 + minute;

  MedTime addMinutes(int minutes) =>
      MedTime.fromMinutes(totalMinutes + minutes);

  String format() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  int compareTo(MedTime other) => totalMinutes.compareTo(other.totalMinutes);

  @override
  List<Object?> get props => [hour, minute];

  @override
  String toString() => format();
}
