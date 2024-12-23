
import 'package:calendar_schedular/component/schedule_bottom_sheet.dart';
import 'package:calendar_schedular/component/schedule_card.dart';
import 'package:calendar_schedular/component/today_banner.dart';
import 'package:calendar_schedular/const/colors.dart';
import 'package:calendar_schedular/provider/schedule_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';


import '../component/main_calendar.dart';
import '../database/drift_database.dart';

//class HomeScreen extends StatefulWidget{

  // const HomeScreen({Key? key}):super(key:key);

  // @override
  // State<HomeScreen> createState()  => _HomescreenState();
  // }

  // class _HomescreenState extends State<HomeScreen>{

class HomeScreen extends StatelessWidget{
    DateTime selectedDate = DateTime.utc(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );


    @override
    Widget build(BuildContext context) {
      // 프로바이더 변경이 있을때마다 build() 함수 재실행
      final provider = context.watch<ScheduleProvider>();
      // 선택된 날짜 가져오기
      final selectedDate = provider.selectedDate;
      // 선택된 날짜에 해당되는 일정들 가져오기
      final schedules = provider.cache[selectedDate] ?? [];

      return Scaffold(
        floatingActionButton: FloatingActionButton( // 새 일정 버튼
            backgroundColor: PRIMARY_COLOR,
            onPressed: () {
              showModalBottomSheet( // BottomSheet 열기
                  context: context,
                  isDismissible: true, // 배경 탭했을때 bottomsheet 닫기
                  builder: (_) => ScheduleBottomSheet(
                    selectDate:  selectedDate, //선택된 날짜(selectedDate) 넘겨주기
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
                  onDaySelected : (selectedDate, focusedDate) =>
                  onDaySelected(selectedDate, focusedDate, context),
                ),
                SizedBox(height: 8.0,),
                  // StreamBuilder<List<Schedule>>(
                  //     stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
                  //     builder: (context, snapshot) {
                  //       return TodayBanner(
                  //         selectedDate: selectedDate,
                  //         count: snapshot.data?.length ?? 0,
                  //       );
                  //     }
                  // ),
                TodayBanner(
                    selectedDate: selectedDate,
                    count: schedules.length
                ),
                SizedBox(height: 8.0),
                // Expanded(
                //   // ➊ 남는 공간을 모두 차지하기
                //   child: StreamBuilder<List<Schedule>>(
                //     // ➋ 일정 정보가 Stream으로 제공되기 때문에 StreamBuilder 사용
                //     stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
                //     builder: (context, snapshot) {
                //       if (!snapshot.hasData) {
                //         // ➌ 데이터가 없을 때
                //         return Container();
                //       }
                //
                //       return ListView.builder(
                //         // ➍ 화면에 보이는 값들만 렌더링하는 리스트
                //         itemCount: snapshot.data!.length, // ➎ 리스트에 입력할 값들의 총 개수
                //         itemBuilder: (context, index) {
                //           final schedule =
                //           snapshot.data![index]; // ➏ 현재 index에 해당되는 일정
                //           return Dismissible(
                //             key: ObjectKey(schedule.id),
                //             // ➊ 유니크한 키값
                //             direction: DismissDirection.startToEnd,
                //             // ➋ 밀기 방향 (오른쪽에서 왼쪽으로)
                //             onDismissed: (DismissDirection direction) {
                //               // ➌ 밀기 했을 때 실행할 함수
                //               GetIt.I<LocalDatabase>().removeSchedule(schedule.id);
                //             },
                //             child: Padding(
                //               padding: const EdgeInsets.only(
                //                   bottom: 8.0, left: 8.0, right: 8.0),
                //               child: ScheduleCard(
                //                 startTime: schedule.startTime,
                //                 endTime: schedule.endTime,
                //                 content: schedule.content,
                //               ),
                //             ),
                //           );
                //         },
                //       );
                //     },
                //   ),
                // ),

                Expanded(
                    child: ListView.builder(
                      itemCount: schedules.length,
                        itemBuilder: (context, index) {
                        final schedule = schedules[index];

                        return Dismissible(
                            key:ObjectKey(schedule.id),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (DismissDirection direction){
                              provider.deleteSchedule(date: selectedDate, id: schedule.id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 8.0, left: 8.0, right: 8.0),
                              child: ScheduleCard(
                                  startTime: schedule.startTime,
                                  endTime: schedule.endTime,
                                  content: schedule.content,
                              ),
                            ),
                        );

                        },
                        ),
                ),
              ],
            ),
        ),
      );
    }

    void onDaySelected(
        DateTime selectedDate,
        DateTime focusedDate,
        BuildContext context
        ){
      // 날짜가 선택될때 마다 실행할 함수
      // setState(() {
      //   this.selectedDate = selectedDate;
      // });
      final provider = context.read<ScheduleProvider>();
      provider.changeSelectedDate(
          date: selectedDate
      );
      provider.getSchedules(date: selectedDate);

    }



}//CLASS