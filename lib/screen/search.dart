import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:heunjeok/controller/book_controller.dart';
import 'package:heunjeok/widgets/search_book.dart';
import 'package:heunjeok/widgets/search_write.dart';

class Search extends StatefulWidget {
  void Function(double) changePadding;
  Search({super.key, required this.changePadding});

  @override
  State<Search> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<Search>
    with SingleTickerProviderStateMixin {
  //Getx의 BookController 찾아서 가져오기
  final BookController bookController = Get.find<BookController>();

  //탭 컨트롤러
  late TabController _tabController;

  //검색창 텍스트
  final TextEditingController _controller = TextEditingController();

  //최근검색어
  List<String> recentSearch = [];

  //Hive 최근검색어 박스
  late Box<String> recentSearchBox;

  @override
  void initState() {
    super.initState();
    // 탭 2개~
    _tabController = TabController(length: 2, vsync: this);
    // Hive에 저장된 최근검색어 불러오기
    recentSearchBox = Hive.box<String>('recentSearchBox');
    recentSearch = recentSearchBox.values.toList().reversed.toList();
    widget.changePadding(18);
  }

  @override
  void dispose() {
    //위젯 종료 시 자원 정리용 함수
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextField(
              controller: _controller,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 25),
                filled: true,
                fillColor: const Color.fromRGBO(182, 187, 121, 1),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                    color: const Color.fromRGBO(182, 187, 121, 1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                    color: const Color.fromRGBO(182, 187, 121, 1),
                  ),
                ),
                hintText: '기록할 도서를 검색해주세요.',
                hintStyle: TextStyle(color: Colors.white),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: IconButton(
                    icon: SvgPicture.asset('search_white.svg'),
                    onPressed: () async {
                      final value = _controller.text.trim();
                      await addRecentSearch(value);
                      bookController.search(_controller.text);
                      _controller.clear();
                    },
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white),

              // 키보드 검색 버튼
              onSubmitted: (value) async {
                await addRecentSearch(value);
                bookController.search(_controller.text);
                _controller.clear();
              },
            ),
          ),
          //최근 검색어
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('최근 검색어'),
              SizedBox(height: 5),
              SizedBox(
                height: 30,
                child: Row(
                  children: recentSearch.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          _controller.text = item;
                          bookController.search(item);
                          addRecentSearch(item);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromRGBO(182, 187, 121, 1),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(item, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),

          // 탭바
          TabBar(
            controller: _tabController,
            labelColor: const Color.fromRGBO(51, 51, 51, 1),
            unselectedLabelColor: Colors.grey,

            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 3.0,
                color: Color.fromRGBO(182, 187, 121, 1),
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab, //밑줄 길이
            tabs: const [
              Tab(
                child: Text(
                  '도서',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  '기록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          //탭뷰
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [SearchBook(), SearchWrite()],
            ),
          ),
        ],
      ),
    );
  }

  // 최근 검색어 Box 저장 함수
  Future<void> addRecentSearch(String value) async {
    if (value.isEmpty) return;

    // 중복 값 확인해서 중복되면 기존 값 삭제해서 갱신
    final existingIndex = recentSearchBox.values.toList().indexOf(value);
    if (existingIndex != -1) {
      await recentSearchBox.deleteAt(existingIndex);
    }

    // 최대 10개 유지
    if (recentSearchBox.length >= 10) {
      await recentSearchBox.deleteAt(0); // 가장 오래된 값 삭제
    }

    await recentSearchBox.add(value);

    setState(() {
      recentSearch = recentSearchBox.values.toList().reversed.toList();
    });
  }
}
