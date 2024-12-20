
import 'package:calendar_schedular/component/schedule_bottom_sheet.dart';
import 'package:calendar_schedular/component/schedule_card.dart';
import 'package:calendar_schedular/component/today_banner.dart';
import 'package:calendar_schedular/const/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../component/main_calendar.dart';
import '../database/drift_database.dart';

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
                  builder: (_) => ScheduleBottomSheet(
                    selectedDate: selectedDate, // 선택된 날짜(selectedDate) 넘겨주기
                  ),
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
                StreamBuilder<List<Schedule>>( // 일정 Stream으로 받아오기
                    stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
                    builder: (context, snapshot){
                      return TodayBanner(
                          selectedDate: selectedDate,
                          count: snapshot.data?.length?? 0, // 일정 개수 입력해주기
                      );
                    }
                ),
                SizedBox(height: 8.0,),
                Expanded( // 남은 공간을 모두 차지하기
                  // 일정 정보가 Stream으로 제공되기 때문ㅇ에 SteamBuilder 사용
                    child: StreamBuilder<List<Schedule>>(
                        stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
                        builder: (context, snapshot) { // 데이터가 없을 때
                          if (!snapshot.hasData) { //데이터가 없을때
                            return Container();
                          }
                          //화면에 보이는 값들만 랜더링하는 리스트
                          return ListView.builder(
                            // 리스트에 입력할 값들의 총갯수
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              //현재 index에 해당되는 일정
                              final schedule = snapshot.data![index];
                              return Dismissible(
                                key: ObjectKey(schedule.id), // 유니크한 키값
                                direction: DismissDirection.startToEnd,
                                //밀기 했을때 실행할 함수
                                onDismissed: (DismissDirection direction) {
                                  GetIt.I<LocalDatabase>().removeSchedule(
                                      schedule.id);
                                },
                                child: Padding( // 좌우로 패딩을 추가해서 ui 개선
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, left: 8.0,
                                      right: 8.0),
                                  child: ScheduleCard(
                                    startTime: schedule.startTime,
                                    endTime: schedule.endTime,
                                    content: schedule.content,
                                  ),
                                ),

                              );
                            },
                          );
                        },
                 ),
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