import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:heunjeok/controller/book_controller.dart';
import 'package:heunjeok/screen/detail.dart';
import 'package:heunjeok/widgets/cover_image.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  void Function(double) changePadding;
  Home({super.key, required this.changePadding});

  @override
  State<Home> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Home> {
  // 각 링크를 Uri로 선언
  final Uri vercel = Uri.parse('https://www.naver.com');
  final Uri github = Uri.parse('https://github.com/mocha-a/heunjeok.git');
  final Uri figma = Uri.parse(
    'https://www.figma.com/design/3Bfs2RCc7jE82qRQeDqJUL/4%EC%B0%A8-mini-Project-%EC%BB%A4%EB%AE%A4%EB%8B%88%ED%8B%B0?node-id=34-1683&t=suYftO5FdlUbrGxh-1',
  );

  // 공통으로 쓰는 launch 함수
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  final BookController bookController = Get.find<BookController>();

  bool isLoading = true;

  List<dynamic> recommend = [];
  List<dynamic> bestseller = [];

  final CardSwiperController controller = CardSwiperController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadAllData();

    //부모것을 가져오려면 widget 넣어줘야함 !
    widget.changePadding(0);
  }

  Future<void> loadAllData() async {
    //2개 api가 다 불러올 때 까지 기다렸다가~
    await Future.wait([recommendApi(), bestsellerApi()]);

    //모두 완료되면 false
    setState(() {
      isLoading = false;
    });
  }

  //알라딘 추천도서 api
  Future<void> recommendApi() async {
    final response = await http.get(
      Uri.parse('http://localhost/heunjeok-server/recommend.php'),
    );

    setState(() {
      recommend = json.decode(response.body);
    });
  }

  //알라딘 베스트셀러 api
  Future<void> bestsellerApi() async {
    final response = await http.get(
      Uri.parse('http://localhost/heunjeok-server/bestseller.php'),
    );

    setState(() {
      bestseller = json.decode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> chunkedBooks = [];

    //베스트셀러 3개씩 묶기
    for (int i = 0; i < bestseller.length; i += 3) {
      chunkedBooks.add(
        bestseller.sublist(
          i,
          i + 3 > bestseller.length ? bestseller.length : i + 3,
        ),
      );
    }

    if (isLoading) {
      return Center(
        child: Image.asset('/loading_green.gif', width: 316, height: 316),
      );
    }

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 700,
              child: CardSwiper(
                cardsCount: recommend.length,
                numberOfCardsDisplayed: 2,
                allowedSwipeDirection: AllowedSwipeDirection.only(
                  left: true,
                  right: true,
                ),
                cardBuilder:
                    (
                      context,
                      index,
                      horizontalOffsetPercentage,
                      verticalOffsetPercentage,
                    ) {
                      var item = recommend[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Detail(id: item["itemId"]),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromRGBO(
                              239,
                              239,
                              239,
                              1,
                            ), // 하단 배경색
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              CoverImage(imagePath: item['cover']!),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 25,
                                    left: 20,
                                    bottom: 30,
                                    right: 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: item['author']!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: ' · ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                              ),
                                            ),
                                            TextSpan(
                                              text: item['publisher']!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                          style: DefaultTextStyle.of(
                                            context,
                                          ).style, // 기본 텍스트 스타일 상속
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Baseline(
                                            baseline: 12,
                                            baselineType:
                                                TextBaseline.alphabetic,
                                            child: SvgPicture.asset(
                                              'assets/quotes_01.svg',
                                              width: 16,
                                              height: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              item['description']!,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                              maxLines: 5,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Baseline(
                                            baseline: 115,
                                            baselineType:
                                                TextBaseline.alphabetic,
                                            child: SvgPicture.asset(
                                              'assets/quotes_02.svg',
                                              width: 16,
                                              height: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
              ),
            ),
            const SizedBox(height: 40),

            //추천도서
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⭐ 책 좀 읽는 사람들의 픽 !',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromRGBO(67, 103, 65, 1),
                      ),
                    ),
                    const SizedBox(height: 17),
                    SizedBox(
                      height: 660,
                      child: CarouselSlider.builder(
                        itemCount: chunkedBooks.length,
                        itemBuilder: (context, pageIndex, realIndex) {
                          final group = chunkedBooks[pageIndex];
                          return Align(
                            // 왼쪽 정렬
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.92, // 너비 제한 (viewportFraction보다 살짝 작게)
                              margin: const EdgeInsets.only(
                                right: 12,
                              ), // 오른쪽에만 여백
                              child: Column(
                                children: group.asMap().entries.map<Widget>((
                                  entry,
                                ) {
                                  int itemIndex = entry.key;
                                  final item = entry.value;
                                  int overallIndex =
                                      pageIndex * 3 + itemIndex + 1;
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              Detail(id: item['itemId']),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 200,
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Image.network(
                                                  item['cover'] ?? '',
                                                  width: 150,
                                                  height: 200,
                                                  fit: BoxFit.cover,
                                                  filterQuality:
                                                      FilterQuality.high,
                                                ),
                                                Positioned(
                                                  left: -12,
                                                  bottom: -10,
                                                  child: Text(
                                                    '$overallIndex',
                                                    style: TextStyle(
                                                      fontSize: 50,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          const Color.fromRGBO(
                                                            242,
                                                            151,
                                                            160,
                                                            1,
                                                          ),
                                                      shadows: [
                                                        Shadow(
                                                          offset: Offset(
                                                            2,
                                                            2,
                                                          ), // 그림자 위치
                                                          blurRadius:
                                                              3, // 흐림 정도
                                                          color:
                                                              const Color.fromRGBO(
                                                                180,
                                                                107,
                                                                115,
                                                                1,
                                                              ).withValues(
                                                                alpha: 0.5,
                                                              ), // 색과 투명도
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['title'] ?? '제목 없음',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "${item['author']} · ${item['publisher']}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  item['pubDate'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromRGBO(
                                                      153,
                                                      153,
                                                      153,
                                                      1,
                                                    ),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: 660,
                          viewportFraction: 0.92, // 살짝 작게 해서 다음 카드 보이게
                          enableInfiniteScroll: false,
                          enlargeCenterPage: false, // 이거 켜면 카드가 튀어나와서 비추
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '흔적',
                    style: TextStyle(
                      fontSize: 31,
                      color: Color.fromRGBO(182, 187, 121, 1),
                      fontFamily: 'Ownglyph',
                    ),
                  ),
                  SizedBox(width: 150, child: Divider()),
                  Text(
                    '''
      대표 : 소연희, 안지현
      서울특별시 강남구 강남대로98길 16
      사업자번호 : 123-45-67890
      heunjeok@gmail.com
                      ''',
                    style: TextStyle(height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => _launchUrl(vercel),
                        icon: SvgPicture.asset('vercel.svg'),
                      ),
                      IconButton(
                        onPressed: () => _launchUrl(github),
                        icon: SvgPicture.asset('git.svg'),
                      ),
                      IconButton(
                        onPressed: () => _launchUrl(figma),
                        icon: SvgPicture.asset('figma.svg'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
