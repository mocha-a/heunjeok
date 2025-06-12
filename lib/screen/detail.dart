import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heunjeok/widgets/cover_image.dart';

// 왼쪽 절반만 보이도록 클리퍼 구현
class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class Detail extends StatefulWidget {
  final int id;
  const Detail({super.key, required this.id});

  @override
  State<Detail> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Detail> {
  List<Map<String, dynamic>>? book; // 책 정보
  List<Map<String, dynamic>> reviews = []; // 리뷰 목록

  final formkey = GlobalKey<FormState>();

  double rating = 2.5; // 기록내용 작성 시 열리는 팝업 초기 별점 값

  @override
  void initState() {
    super.initState();
    print("불러올 id: ${widget.id}");

    // 실제 서버 호출로 변경하기
    fetchBookAndReviews(widget.id);
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
            "이제는 ‘클래식힙’ 트렌드! 유튜브 인기채널 ‘클래식좀들어라’의 플레이리스트를 책으로 만나다  이 책은 구독자들의 뜨거운 사랑을 받은 유튜브 채널 ‘클래식좀들어라’의 플레이리스트를 기반으로, 젊은 감각으로 클래식 음악을 소개하는 신개념 입문서다. 흔히들 생각하는 클래식의 이미지처럼 점잖고 고상한 스타일이 아닌, 톡톡 튀는 재미와 친근함으로 대중들에게 다가간다는 점이 특징이다. 이런 분께 추천합니다! “클래식, 들어야 할 것 같긴 한데 뭐부터 들어야 할지 모르겠어요.” “뻔하고 지루한 교양서, 이제 그만!” “감성 충만한 플레이리스트로 하루를 채우고 싶어요.” “BGM으로만 듣던 클래식, 그 매력을 좀 더 알고 즐기고 싶어요.",
      },
    ];
    setState(() {
      book = foundBook;
      reviews = allReviews.where((r) => r["book_id"] == id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color.fromRGBO(51, 51, 51, 1)),
        ),
        fontFamily: 'SUITE',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
        appBarTheme: AppBarTheme(backgroundColor: Colors.transparent),
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: SvgPicture.asset('back.svg', width: 18),
          ),
        ),
        body: book == null
            ? Center(
                child: Image.asset(
                  'loading_green.gif',
                  width: 316,
                  height: 316,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none, // 음수 위치도 허용
                      children: [
                        CoverImage(imagePath: book![0]['image'], height: 470),
                      ],
                    ),
                    Transform.translate(
                      offset: Offset(0, -20),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${book![0]['title']}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${book![0]['content']}",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${book![0]['edit']!} / ${book![0]['author']}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${book![0]['date']}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 85, 85, 85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 25),
                            Divider(
                              color: Color.fromARGB(255, 153, 153, 153),
                              thickness: 2.5,
                            ),
                            SizedBox(height: 25),
                            Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "독서기록 ${reviews.length}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ...reviews.map((review) {
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              review['nickname'],
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Spacer(),
                                            TextButton(
                                              onPressed: () {},
                                              style: ButtonStyle(
                                                padding:
                                                    MaterialStateProperty.all(
                                                      EdgeInsets.zero,
                                                    ),
                                                minimumSize:
                                                    MaterialStateProperty.all(
                                                      Size(0, 0),
                                                    ),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                      Colors.transparent,
                                                    ),
                                              ),

                                              child: Text(
                                                "수정",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w300,
                                                  color: Color.fromARGB(
                                                    255,
                                                    153,
                                                    153,
                                                    153,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 7),
                                            TextButton(
                                              onPressed: () {},
                                              style: ButtonStyle(
                                                padding:
                                                    MaterialStateProperty.all(
                                                      EdgeInsets.zero,
                                                    ),
                                                minimumSize:
                                                    MaterialStateProperty.all(
                                                      Size(0, 0),
                                                    ),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                      Colors.transparent,
                                                    ),
                                              ),
                                              child: Text(
                                                "삭제",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w300,
                                                  color: Color.fromARGB(
                                                    255,
                                                    153,
                                                    153,
                                                    153,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 3),
                                        Row(
                                          children: [
                                            RatingBarIndicator(
                                              rating: review["rating"],
                                              itemCount: 5,
                                              itemSize: 20,
                                              direction: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                final fullStars =
                                                    review["rating"].floor();
                                                final hasHalfStar =
                                                    (review["rating"] -
                                                        fullStars) >=
                                                    0.5;
                                                if (index < fullStars) {
                                                  // 꽉 찬 별
                                                  return Icon(
                                                    Icons.star_rate_rounded,
                                                    color: Color.fromARGB(
                                                      255,
                                                      242,
                                                      151,
                                                      160,
                                                    ),
                                                  );
                                                } else if (index == fullStars &&
                                                    hasHalfStar) {
                                                  // 반 별 커스텀
                                                  return Stack(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .star_outline_rounded,
                                                        color: Color.fromARGB(
                                                          255,
                                                          242,
                                                          151,
                                                          160,
                                                        ),
                                                      ),
                                                      ClipRect(
                                                        clipper: _HalfClipper(),
                                                        child: Icon(
                                                          Icons
                                                              .star_rate_rounded,
                                                          color: Color.fromARGB(
                                                            255,
                                                            242,
                                                            151,
                                                            160,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  // 빈 별
                                                  return Icon(
                                                    Icons.star_outline_rounded,
                                                    color: Color.fromARGB(
                                                      255,
                                                      242,
                                                      151,
                                                      160,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              width: 0.5,
                                              height: 12,
                                              color: Color.fromARGB(
                                                255,
                                                85,
                                                85,
                                                85,
                                              ),
                                            ),
                                            Text(
                                              "${review['date']}",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w300,
                                                color: Color.fromARGB(
                                                  255,
                                                  85,
                                                  85,
                                                  85,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 3),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "${review['content']}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Divider(
                                          color: Color.fromARGB(
                                            255,
                                            153,
                                            153,
                                            153,
                                          ),
                                          thickness: 1,
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    );
                                  }).toList(),
                                  SizedBox(height: 30),
                                  ElevatedButton(
                                    onPressed: () {
                                      addForm(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(
                                        255,
                                        182,
                                        187,
                                        121,
                                      ),
                                      minimumSize: Size(double.infinity, 44),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                    ),
                                    child: Text(
                                      "흔적 남기기",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  //기록내용 추가 팝업
  void addForm(context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RatingBar.builder(
                            initialRating: rating,
                            minRating: 0.5,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 25,
                            itemPadding: EdgeInsets.symmetric(horizontal: 2),
                            itemBuilder: (context, _) => Icon(
                              Icons.star_rate_rounded,
                              color: Color.fromARGB(255, 242, 151, 160),
                            ),
                            onRatingUpdate: (newRating) {
                              setModalState(() {
                                rating = newRating;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "닉네임을 입력해 주세요!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(labelText: '닉네임'),
                          onSaved: (value) {
                            // schedule = value;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "기록 내용을 입력해 주세요!";
                            }
                            return null;
                          },
                          maxLines: 5,
                          decoration: InputDecoration(labelText: '기록내용'),
                          onSaved: (value) {
                            // daytime = value;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "비밀번호를 입력해 주세요!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(labelText: '비밀번호'),
                          onSaved: (value) {
                            // memo = value;
                          },
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (formkey.currentState!.validate()) {
                              formkey.currentState!.save();
                              //느낌표는 save라는 매소드가 나중에라도 틀림없이 존재한다 라는 의미를 가지고 있음
                              // controller.addSchedule(
                              //   schedule!,
                              //   daytime,
                              //   memo,
                              //   selectedCategory!,
                              //   selectedImportant!,
                              // ); //느낌표가 무조건 string임을 의미
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('기록 내용이 저장되었습니다.'),
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    242,
                                    151,
                                    160,
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 182, 187, 121),
                            elevation: 0,
                          ),
                          child: Text(
                            '저장',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 239, 239, 239),
                            elevation: 0,
                          ),
                          child: Text(
                            '취소',
                            style: TextStyle(
                              color: Color.fromARGB(255, 51, 51, 51),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
