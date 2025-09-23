import 'measurement.dart';

/// Smart filtering utilities for measurements
class SmartFiltering {
  /// Apply smart filtering to measurements
  static List<dynamic> applySmartFiltering({
    required List<Measurement> measurements,
    bool showSlowOnly = false,
    Duration? slowThreshold,
    bool hideUltraFast = false,
    Duration? ultraFastThreshold,
    bool groupSimilar = false,
    Duration? similarThreshold,
  }) {
    if (measurements.isEmpty) {
      return [];
    }

    // Step 1: Filter by slow threshold
    List<Measurement> filtered = measurements;
    if (showSlowOnly && slowThreshold != null) {
      filtered = measurements
          .where((m) => m.duration >= slowThreshold)
          .toList();
    }

    // Step 2: Filter out ultra fast
    if (hideUltraFast && ultraFastThreshold != null) {
      filtered = filtered
          .where((m) => m.duration >= ultraFastThreshold)
          .toList();
    }

    // Step 3: Group similar if needed
    List<dynamic> result = [];
    if (groupSimilar && similarThreshold != null && filtered.isNotEmpty) {
      final groups = groupSimilarMeasurements(filtered, similarThreshold);
      result.addAll(groups);
    } else {
      result.addAll(filtered);
    }

    return result;
  }

  /// Group measurements with similar durations
  static List<GroupedMeasurement> groupSimilarMeasurements(
    List<Measurement> measurements,
    Duration similarThreshold,
  ) {
    if (measurements.isEmpty) {
      return [];
    }

    final List<GroupedMeasurement> groups = [];
    final Set<int> processed = {};

    for (int i = 0; i < measurements.length; i++) {
      if (processed.contains(i)) {
        continue;
      }

      final m1 = measurements[i];
      
      // Create new group
      var groupName = m1.statement;
      var count = 1;
      var totalTime = m1.duration;
      var minTime = m1.duration;
      var maxTime = m1.duration;
      
      processed.add(i);

      // Find similar measurements
      final List<String> similarNames = [];
      for (int j = i + 1; j < measurements.length; j++) {
        if (processed.contains(j)) {
          continue;
        }

        final m2 = measurements[j];
        final diff = (m1.duration - m2.duration).abs();

        if (diff <= similarThreshold) {
          count++;
          totalTime += m2.duration;
          if (m2.duration < minTime) {
            minTime = m2.duration;
          }
          if (m2.duration > maxTime) {
            maxTime = m2.duration;
          }
          similarNames.add(m2.statement);
          processed.add(j);
        }
      }

      // Calculate average time
      final avgTime = Duration(
        microseconds: totalTime.inMicroseconds ~/ count,
      );

      // Update group name if we have similar operations
      if (similarNames.isNotEmpty) {
        if (similarNames.length <= 2) {
          groupName = '$groupName + ${similarNames.length} similar';
        } else {
          groupName = '$groupName + ${similarNames.length} others';
        }
      }

      groups.add(GroupedMeasurement(
        name: groupName,
        count: count,
        totalTime: totalTime,
        avgTime: avgTime,
        minTime: minTime,
        maxTime: maxTime,
      ));
    }

    return groups;
  }
}
