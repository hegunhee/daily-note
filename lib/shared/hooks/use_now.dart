import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';

/// 30초마다 다시 읽는 지금 시각. 진행 중 표시가 시각이 지나면 저절로 바뀌게 합니다.
DateTime useNow(DateTime Function() clock) {
  final now = useState(clock());
  useEffect(() {
    now.value = clock();
    final timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => now.value = clock(),
    );
    return timer.cancel;
  }, [clock]);
  return now.value;
}
