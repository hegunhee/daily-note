import 'package:flutter/widgets.dart';
import 'package:greenlist/core/themes/app_layout.dart';

/// 본문을 [AppLayout.contentMaxWidth]로 묶고 가운데 정렬합니다.
///
/// 폰에서는 아무 영향이 없습니다. 태블릿에서만 좌우에 여백이 생기고 카드가 폰과 같은
/// 크기로 유지됩니다. 높이는 자식만큼만 차지해 하단 바 안에서도 쓸 수 있습니다.
class AppContentWidth extends StatelessWidget {
  const AppContentWidth({required this.child, super.key});

  /// 폭을 묶을 대상
  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppLayout.contentMaxWidth),
      child: child,
    ),
  );
}
