import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:heunjeok/controller/book_controller.dart';
import 'package:heunjeok/screen/detail.dart';

class SearchBook extends StatefulWidget {
  const SearchBook({Key? key}) : super(key: key);

  @override
  State<SearchBook> createState() => _SearchBookState();
}

class _SearchBookState extends State<SearchBook> {
  //Getx의 BookController 찾아서 가져오기
  final BookController bookController = Get.find<BookController>();

  //스크롤
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 스크롤 리스너 등록
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final query = bookController.currentQuery.value;
        if (query.isNotEmpty) {
          bookController.search(query, isLoadMore: true);
        }
      }
    });
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
      if (bookController.isLoading.value && bookController.books.isEmpty) {
        return Center(child: Image.asset('assets/loading_green.gif'));
      }

      final books = bookController.books;

      if (books.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/nobook.svg'),
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
                  text: '${bookController.total.value}',
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
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.58,
              ),
              itemCount:
                  books.length + (bookController.isLoading.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == books.length) {
                  // 로딩 중일 때 리스트 끝에 로딩 인디케이터 보여주기
                  return Center(child: Image.asset('assets/loading_green.gif'));
                }
                final book = books[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Detail(id: book['itemId']),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 3 / 4,
                        child:
                            //이미지 없을때, 알라딘에서 기본 이미지 제공하지만 못생겨서 커스텀
                            (book['cover'] ==
                                'https://image.aladin.co.kr/img/noimg_sum_b.gif')
                            ? Image.asset('noimage.png', fit: BoxFit.cover)
                            : Image.network(
                                book['cover'],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book['title'] ?? '',
                        style: const TextStyle(fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${book['author']} · ${book['publisher']}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(85, 85, 85, 1),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
