import 'dart:math';

abstract class Rng {
  int nextInt(int max);
  double nextDouble();
}

class RandomRng implements Rng {
  final Random _random;

  RandomRng([Random? random]) : _random = random ?? Random();

  @override
  int nextInt(int max) => _random.nextInt(max);

  @override
  double nextDouble() => _random.nextDouble();
}
