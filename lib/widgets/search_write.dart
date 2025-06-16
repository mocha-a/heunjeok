import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:heunjeok/controller/book_controller.dart';
import 'package:heunjeok/utils/scroll_listener.dart';
import 'package:heunjeok/widgets/book_item.dart';
import 'package:heunjeok/widgets/dialog.dart';

class SearchWrite extends StatefulWidget {
  const SearchWrite({super.key});

  @override
  State<SearchWrite> createState() => _SearchWriteState();
}

class _SearchWriteState extends State<SearchWrite> {
  //Getx의 BookController 찾아서 가져오기
  final BookController bookController = Get.find<BookController>();

  //스크롤
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 스크롤 리스너 등록
    _scrollController = scroll(
      onReachBottom: () {
        final query = bookController.currentQuery.value;
        if (query.isNotEmpty) {
          bookController.writeSearch(query, isLoadMore: true);
        }
      },
    );
  }

  @override
  void dispose() {
    //위젯 종료 시 자원 정리용 함수
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (bookController.isLoading.value && bookController.writes.isEmpty) {
        return Center(child: Image.asset('assets/loading_green.gif'));
      }

      final writes = bookController.writes;

      if (writes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/nowrite.svg'),
              const SizedBox(height: 10),
              const Text('검색 결과가 없습니다.'),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${bookController.writeTotal.value}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(242, 151, 160, 1),
                  ),
                ),
                const TextSpan(
                  text: '개의 도서를 찾았습니다 !',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(62, 103, 65, 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount:
                  writes.length + (bookController.isLoading.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == writes.length) {
                  // 로딩 중일 때 리스트 끝에 로딩 인디케이터 보여주기
                  return Center(child: Image.asset('assets/loading_green.gif'));
                }
                final write = writes[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: BookItem(
                    image: write["book_cover"] ?? '이미지 없음',
                    nickname: write["nickname"] ?? '닉네임 없음',
                    date: write["date"] ?? '날짜 없음',
                    content: write["content"] ?? '내용 없음',
                    onTap: () {
                      alertDialog(context, write);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  void alertDialog(BuildContext context, Map<String, dynamic> bookItem) {
    showDialog(
      context: context,
      builder: (context) => ReviewDialog(bookItem: bookItem),
    );
  }
}
