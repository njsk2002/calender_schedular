
import 'package:calendar_schedular/component/schedule_bottom_sheet.dart';
import 'package:calendar_schedular/component/schedule_card.dart';
import 'package:calendar_schedular/component/today_banner.dart';
import 'package:calendar_schedular/const/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../component/main_calendar.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({Key? key}):super(key:key);

  @override
  State<HomeScreen> createState()  => _HomescreenState();
  }

  class _HomescreenState extends State<HomeScreen>{

    DateTime selectedDate = DateTime.utc(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        floatingActionButton: FloatingActionButton( // 새 일정 버튼
            backgroundColor: PRIMARY_COLOR,
            onPressed: () {
              showModalBottomSheet( // BottomSheet 열기
                  context: context,
                  isDismissible: true, // 배경 탭했을때 bottomsheet 닫기
                  builder: (_) => ScheduleBottomSheet(),
                //BottomSheet 높이를 화면의 최대 높이로 정의하고 스크롤 가능하게 변경
                isScrollControlled: true,
              );
            },
          child: Icon(
            Icons.add,
          ),
        ),
        body: SafeArea(  // 시스템 ui 피해서 ui 구현하기
            child: Column( // 달력과 리스트를 새로로 배치
              children: [
                //미리 작업해둔 달력 위젯 보여주기
                MainCalendar(
                  selectedDate : selectedDate,
                  // 날짜가 선택됐을때 실행할 함수
                  onDaySelected : onDaySelected,
                ),
                SizedBox(height: 8.0,),
                TodayBanner(
                    selectedDate: selectedDate,
                    count: 0,
                ),
                SizedBox(height: 8.0,),
                ScheduleCard( // 구현해둔 일정 카드
                    startTime: 12,
                    endTime: 14,
                    content: '프로그래밍 공부',
                ),

              ],
            ),
        ),
      );
    }

    void onDaySelected(DateTime selectedDate, DateTime focusedDate){
      // 날짜가 선택될때 마다 실행할 함수
      setState(() {
        this.selectedDate = selectedDate;
      });
    }



}//CLASS