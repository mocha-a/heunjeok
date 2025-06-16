import 'package:flutter/widgets.dart';

/// 스크롤이 끝에 닿았을 때 [onReachBottom] 콜백 실행
ScrollController scroll({
  required void Function() onReachBottom,
  double offset = 200,
}) {
  final ScrollController scrollController = ScrollController();

  scrollController.addListener(() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - offset) {
      onReachBottom();
    }
  });

  return scrollController;
}
