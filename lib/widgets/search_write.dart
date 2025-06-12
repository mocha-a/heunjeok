import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:heunjeok/controller/book_controller.dart';

class SearchWrite extends StatelessWidget {
  SearchWrite({Key? key}) : super(key: key);

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
              SvgPicture.asset('nowrite.svg'),
              SizedBox(height: 8),
              Text('검색 결과가 없습니다.'),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return ListTile(
            title: Text(book['title'] ?? '제목 없음'),
            subtitle: Text(book['author'] ?? '저자 없음'),
          );
        },
      );
    });
  }
}
