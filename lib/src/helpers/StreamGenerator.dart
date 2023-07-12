/// start the first callback with the stream
Stream<int> generateStream(Duration duration) async* {
  yield 0;

  await for (var i in Stream.periodic(Duration(minutes: 1), (i) => i)) {
    yield i + 1;
  }
}
