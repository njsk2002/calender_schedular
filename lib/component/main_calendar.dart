

import 'package:calendar_schedular/const/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';

class MainCalendar extends StatelessWidget{
  final OnDaySelected onDaySelected; // 날짜선택 시 실행할 함수
  final DateTime selectedDate; //선택된날짜

  MainCalendar({
    required this.onDaySelected,
    required this.selectedDate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_kr', // 한국어로 언어변경
      onDaySelected: onDaySelected,
      //날짜 선ㅌ개시 실행할 함수
      selectedDayPredicate: (date) => // 선택된 날짜를 구분할 로직
        date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day,
      firstDay: DateTime(1800,1,1), //첫째날
      lastDay: DateTime(3000,1,1), //마지막날
      focusedDay: DateTime.now(), // 화면에 보여지는 날
      headerStyle:  HeaderStyle( // 달력 최상단 스타일
        titleCentered:  true, // 제목 중앙 위치하기
        formatButtonVisible: false, // 달력크기 선택 옵션 없애기
        titleTextStyle: TextStyle( // 제목글꼴
          fontWeight: FontWeight.w700,
          fontSize: 16.0,
        ),
      ),
      calendarStyle: CalendarStyle(
        isTodayHighlighted: false,
        defaultDecoration: BoxDecoration(//기본 날짜 스타일
          borderRadius: BorderRadius.circular(6.0),
          color: LIGHT_GREY_COLOR,
        ),
        weekendDecoration: BoxDecoration( // 주말 날짜 스타일
          borderRadius: BorderRadius.circular(6.0),
          color: LIGHT_GREY_COLOR,
        ),
        selectedDecoration: BoxDecoration( // 선택된 날짜 스타일
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: PRIMARY_COLOR,
            width: 1.0,
          ),
        ),
        defaultTextStyle: TextStyle( // 기본글꼴
          fontWeight: FontWeight.w600,
          color: DARK_GREY_COLOR,
        ),
        weekendTextStyle: TextStyle(//주말글꼴
          fontWeight: FontWeight.w600,
          color: DARK_GREY_COLOR,

        ),
        selectedTextStyle: TextStyle( //선택된 날짜 글꼴
          fontWeight: FontWeight.w600,
          color: PRIMARY_COLOR,
        ),
      ),

    );
  }

}