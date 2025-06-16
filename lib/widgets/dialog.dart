import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:heunjeok/screen/detail.dart';

class ReviewDialog extends StatelessWidget {
  const ReviewDialog({super.key, required this.bookItem});

  final Map<String, dynamic> bookItem;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              "${bookItem["book_publisher"]} / ${bookItem["book_author"]}",
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
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
                    RatingBar(
                      initialRating: bookItem["rating"].toDouble(), // 예: 3.5
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      ignoreGestures: true, //읽기 전용
                      itemCount: 5,
                      itemSize: 20,
                      ratingWidget: RatingWidget(
                        full: Icon(
                          Icons.star_rate_rounded,
                          color: Color.fromRGBO(242, 151, 160, 1), //꽉 찬 별
                        ),
                        half: Icon(
                          Icons.star_half_rounded,
                          color: Color.fromRGBO(242, 151, 160, 1), //반 별
                        ),
                        empty: Icon(
                          Icons.star_outline_rounded,
                          color: Color.fromRGBO(242, 151, 160, 1), //빈 별
                        ),
                      ),
                      onRatingUpdate: (_) {}, //필수 옵션이라 비어 둠
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
  }
}
