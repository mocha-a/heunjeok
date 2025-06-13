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
    // print("불러올 id: ${widget.id}");

    // 실제 서버 호출로 변경하기
    fetchBookAndReviews(1);
    widget.changePadding(18);
  }

  void fetchBookAndReviews(int id) async {
    // // 1. 책 정보 요청
    // final fetchedBook = await getBookById(bookId);
    // // 2. 리뷰 목록 요청
    // final fetchedReviews = await getReviewsByBookId(bookId);
    final List<Map<String, dynamic>> allReviews = [
      {
        "book_id": 1,
        "nickname": "울먹거리는 쿼카",
        "date": "2025-06-10",
        "content": "너무 기뻐서 바로 구매했습니다.",
        "rating": 2.5,
      },
      {
        "book_id": 1,
        "nickname": "조용한 고슴도치",
        "date": "2025-04-24",
        "content": "기분이 가라앉을 때 좋아요.",
        "rating": 4.5,
      },
    ];

    final List<Map<String, dynamic>> foundBook = [
      {
        "id": 1,
        "title": "클래식 좀 들어라",
        "author": "망둥어,해달",
        "edit": "더스퀘어",
        "image": "assets/image.jpg",
        "date": "2025.05.20",
        "content":
            "이제는 ‘클래식힙’ 트렌드!유튜브 인기채널 ‘클래식좀들어라’의 플레이리스트를 책으로 만나다이 책은 구독자들의 뜨거운 사랑을 받은 유튜브 채널 ‘클래식좀들어라’의 플레이리스트를 기반으로, 젊은감각으로 클래식 음악을 소개하는 신개념 입문서다. 흔히들 생각하는 클래식의 이미지처럼 점잖고 고상한스타일이 아닌, 톡톡 튀는 재미와 친근함으로 대중들에게 다가간다는 점이 특징이다.이런 분께 추천합니다!“클래식, 들어야 할 것 같긴 한데 뭐부터 들어야 할지 모르겠어요.”“뻔하고 지루한 교양서, 이제 그만!”“감성 충만한 플레이리스트로 하루를 채우고 싶어요.”“BGM으로만 듣던 클래식, 그 매력을 좀 더 알고 즐기고 싶어요.",
      },
    ];
    setState(() {
      book = foundBook;
      reviews = allReviews.where((r) => r["book_id"] == id).toList();
    });
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
                // 해당 리뷰의 책 이미지 가져오기
                final matchedBook = book.firstWhere(
                  (b) => b["id"] == review["book_id"],
                  orElse: () => {},
                );
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: BookItem(
                    image: matchedBook["image"],
                    nickname: review["nickname"],
                    date: review["date"],
                    content: review["content"],
                    onTap: () {
                      alertDialog(context, matchedBook, review);
                      print('책 클릭 ID값 : ${matchedBook["id"]}');
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
  void alertDialog(
    ctx,
    Map<String, dynamic> bookItem,
    Map<String, dynamic> reviewItem,
  ) {
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
                    Image.asset(
                      bookItem["image"],
                      width: 81,
                      height: 107,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookItem["title"],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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
                                  Text(bookItem["edit"]),
                                  Text(" / "),
                                  Text(bookItem["author"]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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
                          reviewItem["nickname"],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Color.fromARGB(255, 85, 85, 85),
                          ),
                        ),
                        Spacer(),
                        RatingBarIndicator(
                          rating: reviewItem["rating"],
                          itemCount: 5,
                          itemSize: 20,
                          direction: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final fullStars = reviewItem["rating"].floor();
                            final hasHalfStar =
                                (reviewItem["rating"] - fullStars) >= 0.5;

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
                      reviewItem["content"],
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
                        reviewItem["date"],
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
                  MaterialPageRoute(builder: (_) => Detail(id: bookItem["id"])),
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
