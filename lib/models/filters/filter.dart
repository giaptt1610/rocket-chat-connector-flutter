export 'channel_counters_filter.dart';
export 'channel_filter.dart';
export 'channel_history_filter.dart';
export 'room_counters_filter.dart';
export 'room_filter.dart';
export 'room_history_filter.dart';

abstract class Filter {
  Map<String, dynamic> toMap();
}
