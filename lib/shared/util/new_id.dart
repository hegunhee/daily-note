import 'dart:math';

final _random = Random();

/// 새 일정·세부 작업의 id. 같은 마이크로초에 여러 개를 만들어도 겹치지 않게 난수를 붙입니다.
String newId() =>
    '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';
