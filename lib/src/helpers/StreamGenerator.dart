/// start the first callback with the stream
Stream<int> generateStream(Duration duration) async* {
  yield 0;

  await for (var i in Stream.periodic(duration, (i) => i)) {
    yield i + 1;
  }
}
