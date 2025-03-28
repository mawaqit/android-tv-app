import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

enum SearchSelectionType {
  mosque,
  home,
}

final mosqueManagerProvider = StateProvider<Option<SearchSelectionType>>((ref) {
  return Option.fromNullable(null);
});
