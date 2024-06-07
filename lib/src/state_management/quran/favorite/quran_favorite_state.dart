import 'package:equatable/equatable.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

class QuranFavoriteState extends Equatable {
  final List<ReciterModel> favoriteReciters;
  final MoshafModel? favoriteMoshafs;

  QuranFavoriteState({
    required this.favoriteReciters,
    this.favoriteMoshafs,
  });

  QuranFavoriteState copyWith({
    List<ReciterModel>? favoriteReciters,
    MoshafModel? favoriteMoshafs,
  }) {
    return QuranFavoriteState(
      favoriteReciters: favoriteReciters ?? this.favoriteReciters,
      favoriteMoshafs: favoriteMoshafs ?? this.favoriteMoshafs,
    );
  }

  @override
  List<Object?> get props => [favoriteReciters, favoriteMoshafs];
}
