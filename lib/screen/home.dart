import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:heunjeok/controller/book_controller.dart';
import 'package:heunjeok/screen/detail.dart';
import 'package:heunjeok/widgets/cover_image.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

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

  final BookController bookController = Get.put(BookController());

  bool isLoading = true;
  List<dynamic> books = [];
  List<dynamic> books2 = [];

  final CardSwiperController controller = CardSwiperController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([loadBooks(), recommend()]);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadBooks() async {
    String jsonString = await rootBundle.loadString('aaaaa.json');
    List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      books = jsonData;
    });
  }

  Future<void> recommend() async {
    String jsonString = await rootBundle.loadString('bbbbb.json');
    List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      books2 = jsonData;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> chunkedBooks = [];

    for (int i = 0; i < books.length; i += 3) {
      chunkedBooks.add(
        books.sublist(i, i + 3 > books.length ? books.length : i + 3),
      );
    }

    if (isLoading) {
      return Center(child: Image.asset('/loading_green.gif'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 700,
            child: CardSwiper(
              cardsCount: books2.length,
              numberOfCardsDisplayed: 2,
              cardBuilder:
                  (
                    context,
                    index,
                    horizontalOffsetPercentage,
                    verticalOffsetPercentage,
                  ) {
                    var item = books2[index];
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          baselineType: TextBaseline.alphabetic,
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
                                          baselineType: TextBaseline.alphabetic,
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
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '책 좀 읽는 사람들의 픽 !',
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
                          margin: const EdgeInsets.only(right: 12), // 오른쪽에만 여백
                          child: Column(
                            children: group.asMap().entries.map<Widget>((
                              entry,
                            ) {
                              int itemIndex = entry.key;
                              final item = entry.value;
                              int overallIndex = pageIndex * 3 + itemIndex + 1;
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
                                              filterQuality: FilterQuality.high,
                                            ),
                                            Positioned(
                                              left: -12,
                                              bottom: -10,
                                              child: Text(
                                                '$overallIndex',
                                                style: TextStyle(
                                                  fontSize: 50,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color.fromRGBO(
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
                                                      blurRadius: 3, // 흐림 정도
                                                      color:
                                                          const Color.fromRGBO(
                                                            180,
                                                            107,
                                                            115,
                                                            1,
                                                          ).withOpacity(
                                                            0.5,
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
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${item['author']} · ${item['publisher']}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                                              overflow: TextOverflow.ellipsis,
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
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('흔적'),
                Container(width: 100, child: Divider()),
                Text('대표 : 소연희, 안지현'),
                Text('서울특별시 강남구 강남대로98길 16'),
                Text('사업자번호 : 123-45-67890'),
                Text('heunjeok@gmail.com'),
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
        ],
      ),
    );
  }
}
