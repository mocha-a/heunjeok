import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heunjeok/screen/detail.dart';
import 'package:heunjeok/widgets/book_item.dart';

// 왼쪽 절반만 보이도록 클리퍼 구현
class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class Book extends StatefulWidget {
  void Function(double) changePadding;
  Book({super.key, required this.changePadding});

  @override
  State<Book> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Book> {
  List<Map<String, dynamic>> book = []; // 책 정보
  List<Map<String, dynamic>> reviews = []; // 리뷰 목록

  @override
  void initState() {
    super.initState();
    widget.changePadding(18);
    // 서버 호출
    fetchAllReviews();
  }

  Future<void> fetchAllReviews() async {
    final response = await http.get(
      Uri.parse('http://localhost/heunjeok-server/bookreviews/all_get.php'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      print(response.body);

      // 책별로 묶거나 전체 리뷰 표시 등 원하는대로 처리
      setState(() {
        reviews = data
            .map(
              (item) => {
                "book_id": item["book_id"] ?? 0,
                "book_title": item["book_title"] ?? '',
                "book_author": item["book_author"] ?? '',
                "book_publisher": item["book_publisher"] ?? '',
                "book_cover": item["book_cover"] ?? '',
                "nickname": item["nickname"] ?? '',
                "content": item["content"] ?? '',
                "rating": item["rating"] ?? 0,
                "date": item["date"] ?? '',
                "password": item["password"] ?? '',
              },
            )
            .toList();
      });
    } else {
      print("서버 응답 오류: ${response.statusCode}");
    }
  }

  bool isLatestSort = true;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sortedReviews = List.from(reviews);

    if (isLatestSort) {
      sortedReviews.sort((a, b) => b["date"].compareTo(a["date"]));
    } else {
      sortedReviews.sort((a, b) => b["rating"].compareTo(a["rating"]));
    }

    return Column(
      children: [
        SizedBox(height: 25),
        if (reviews.isNotEmpty) ...[
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${reviews.length}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 242, 151, 160),
                      ),
                    ),
                    TextSpan(
                      text: "개의 독서기록이 있습니다!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 67, 103, 65),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.resolveWith<Color?>((
                    Set<MaterialState> states,
                  ) {
                    if (states.contains(MaterialState.hovered)) {
                      return Color.fromARGB(50, 182, 187, 121);
                    }
                    if (states.contains(MaterialState.pressed)) {
                      return Color.fromARGB(100, 182, 187, 121);
                    }
                    return null; // 기본값
                  }),
                ),
                onPressed: () {
                  setState(() {
                    isLatestSort = !isLatestSort;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      isLatestSort ? "최신순" : "별점순",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 51, 51, 51),
                      ),
                    ),
                    SizedBox(width: 6),
                    SvgPicture.asset("recycle.svg"),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: sortedReviews.length,
              itemBuilder: (context, idx) {
                final review = sortedReviews[idx];
                // // 해당 리뷰의 책 이미지 가져오기
                // final matchedBook = book.firstWhere(
                //   (b) => b["id"] == review["book_id"],
                //   orElse: () => {},
                // );
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: BookItem(
                    image: review["book_cover"] ?? '이미지 없음',
                    nickname: review["nickname"] ?? '닉네임 없음',
                    date: review["date"] ?? '날짜 없음',
                    content: review["content"] ?? '내용 없음',
                    onTap: () {
                      alertDialog(context, review);
                      print('책 클릭 ID값 : ${review["id"]}');
                    },
                  ),
                );
              },
            ),
          ),
        ] else ...[
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 150),
                Image.asset('nolist.png', width: 176),
              ],
            ),
          ),
        ],
      ],
    );
  }

  //클릭 시 기록 확인 팝업
  void alertDialog(ctx, Map<String, dynamic> bookItem) {
    showDialog(
      context: ctx,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.all(24),
          actionsAlignment: MainAxisAlignment.center,
          content: SizedBox(
            width: 287,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      bookItem["book_cover"],
                      width: 81,
                      height: 107,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookItem["book_title"],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              DefaultTextStyle(
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                                child: Row(
                                  children: [
                                    Text(bookItem["book_publisher"]),
                                    Text(" / "),
                                    Text(
                                      bookItem["book_author"],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          bookItem["nickname"],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Color.fromARGB(255, 85, 85, 85),
                          ),
                        ),
                        Spacer(),
                        RatingBarIndicator(
                          rating: bookItem["rating"],
                          itemCount: 5,
                          itemSize: 20,
                          direction: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final fullStars = bookItem["rating"].floor();
                            final hasHalfStar =
                                (bookItem["rating"] - fullStars) >= 0.5;

                            if (index < fullStars) {
                              // 꽉 찬 별
                              return Icon(
                                Icons.star_rate_rounded,
                                color: Color.fromARGB(255, 242, 151, 160),
                              );
                            } else if (index == fullStars && hasHalfStar) {
                              // 반 별 커스텀
                              return Stack(
                                children: [
                                  Icon(
                                    Icons.star_outline_rounded,
                                    color: Color.fromARGB(255, 242, 151, 160),
                                  ),
                                  ClipRect(
                                    clipper: _HalfClipper(),
                                    child: Icon(
                                      Icons.star_rate_rounded,
                                      color: Color.fromARGB(255, 242, 151, 160),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              // 빈 별
                              return Icon(
                                Icons.star_outline_rounded,
                                color: Color.fromARGB(255, 242, 151, 160),
                              );
                            }
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 5),
                    Text(
                      bookItem["content"],
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        bookItem["date"],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          color: Color.fromARGB(255, 85, 85, 85),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                fixedSize: Size(110, 25),
                backgroundColor: Color.fromARGB(255, 182, 187, 121),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Detail(id: int.parse(bookItem["book_id"])),
                  ),
                );
              },
              child: Text(
                "이 책, 궁금해요",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                fixedSize: Size(110, 25),
                backgroundColor: Color.fromARGB(255, 239, 239, 239),
                foregroundColor: Color.fromARGB(255, 51, 51, 51),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 닫기
              },
              child: Text(
                "닫기",
                style: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 51, 51, 51),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
