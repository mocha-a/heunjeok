import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:heunjeok/controller/book_controller.dart';

class SearchBook extends StatelessWidget {
  SearchBook({Key? key}) : super(key: key);

  final BookController bookController = Get.find<BookController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (bookController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final books = bookController.books;

      if (books.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('nobook.svg'),
              SizedBox(height: 10),
              Text('검색 결과가 없습니다.'),
            ],
          ),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            child: Text.rich(
              //여러가지 스타일의 텍스트를 하나로 보여줌
              TextSpan(
                children: [
                  TextSpan(
                    text: '${books.length}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromRGBO(242, 151, 160, 1),
                    ),
                  ),
                  TextSpan(
                    text: '개의 도서를 찾았습니다 !',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromRGBO(62, 103, 65, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              shrinkWrap: true,
              childAspectRatio: 0.5,
              children: books.map((book) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4, // 이미지 비율 맞추기 좋음
                      child: Image.network(book['cover'], fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book['title'] ?? '',
                      style: TextStyle(fontSize: 18),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${book['author']} · ${book['publisher']}",
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color.fromRGBO(85, 85, 85, 1),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }
}
