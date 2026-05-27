
import 'package:flutter_riverpod/legacy.dart';

/// Tracks which bottom nav tab is active
final navIndexProvider = StateProvider<int>((ref) => 0);