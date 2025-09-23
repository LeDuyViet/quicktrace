/// Represents a single measurement with statement and duration
class Measurement {
  /// The statement or operation name
  final String statement;
  
  /// The duration of the operation
  final Duration duration;

  const Measurement({
    required this.statement,
    required this.duration,
  });

  @override
  String toString() => 'Measurement(statement: $statement, duration: $duration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Measurement &&
          runtimeType == other.runtimeType &&
          statement == other.statement &&
          duration == other.duration;

  @override
  int get hashCode => statement.hashCode ^ duration.hashCode;
}

/// Represents a group of similar measurements
class GroupedMeasurement {
  /// The grouped operation name
  final String name;
  
  /// Number of operations in this group
  final int count;
  
  /// Total time of all operations
  final Duration totalTime;
  
  /// Average time per operation
  final Duration avgTime;
  
  /// Minimum time in the group
  final Duration minTime;
  
  /// Maximum time in the group
  final Duration maxTime;

  const GroupedMeasurement({
    required this.name,
    required this.count,
    required this.totalTime,
    required this.avgTime,
    required this.minTime,
    required this.maxTime,
  });

  @override
  String toString() => 'GroupedMeasurement(name: $name, count: $count, avgTime: $avgTime)';
}
