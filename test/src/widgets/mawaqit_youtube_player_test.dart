import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/widgets/mawaqit_youtube_palyer.dart';

void main() {
  test('channel to video id converter', () async {
    const testChannel = 'UCwVQIkAtyZzQSA-OY1rsGig';

    final value = await MawaqitYoutubePlayer.getStreamVideoId(testChannel);

    expect(value, isNotNull);
  });
}
