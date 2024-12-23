

import 'package:calendar_schedular/model/schedule_model.dart';
import 'package:calendar_schedular/repository/schedule_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class ScheduleProvider extends ChangeNotifier{
  final ScheduleRepository repository; //API 요청 로직을 담은 클래스

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  Map<DateTime, List<ScheduleModel>> cache = {}; //일정 정보를 저장해둘 변수

  ScheduleProvider({
    required this.repository,
}) : super() {
    getSchedules(date: selectedDate);
  }

  void getSchedules ({
    required DateTime date,
  }) async{
    final resp = await repository.getSchedules(date: date);//get 메서드보내기
    
    //선택한 날짜의 일정을 업데이트하기
    cache.update(date, (value) => resp, ifAbsent: () => resp);
    
    notifyListeners(); //리슨하는 위젯 업데이트하기
  }


  // Create
  void createSchedule({
    required ScheduleModel schedule,
}) async {
    final targetDate = schedule.date;

    final uuid = Uuid();
    final tempId = uuid.v4(); // 유니크한 id값 생성
    final newSchdule = schedule.copyWith(
      id : tempId, //임시 ID를 지정
    );

    // 긍정적 응답 구간, 서버에서 응답을 받기 전에 캐시를 먼저 업그레이드
    cache.update(
      targetDate,
        (value) => [
          ...value,
          newSchdule,
        ]..sort(
            (a, b) => a.startTime.compareTo(
              b.startTime,
            ),
        ),
      ifAbsent: () => [newSchdule],
    );

    notifyListeners(); //캐쉬 업데이트 반영하기

    try{
      // API 요청
      final savedSchedule = await repository.createSchedule(schedule: schedule);

      cache.update( // 서버 응답 기반으로 캐시 업데이트
        targetDate,
          (value) => value
          .map((e) => e.id == tempId
          ? e.copyWith(
          id: savedSchedule,
          )
          : e)
          .toList(),
          );
      } catch (e) {
      cache.update( // 삭제 실패 시 캐시 롤백하기
        targetDate,
          (value) => value.where((e) => e.id != tempId).toList(),
      );
    }

    // final savedSchedule = await repository.createSchedule(schedule: schedule);
    //
    // cache.update(
    //   targetDate,
    //     (value) => [ // 현존하는 캐시 리스트 끝에 새로운 일정 추가
    //       ...value,
    //       schedule.copyWith(
    //         id: savedSchedule,
    //       ),
    //     ]..sort(
    //         (a, b) => a.startTime.compareTo(
    //           b.startTime,
    //         ),
    //     ),
    //   // 날짜에 해당되는 값이 없다면 새로운 리스트에 새로운 일정 하나만 추가
    //   ifAbsent: () => [schedule],
    // );

    notifyListeners();
  }

  //DELETE
  void deleteSchedule({
    required DateTime date,
    required String id,
}) async {
    // final resp = await repository.deleteSchdule(id: id);
    final targetSchedule = cache[date]!.firstWhere(
        (e) => e.id == id,
    ); // 삭제할 일정 기억

    cache.update( // 캐시에서 데이터 삭제
        date,
        (value) => value.where((e) => e.id !=id).toList(),
      ifAbsent: () => [],
    );// 긍정적 응답(응답전에 캐시 먼저 업그레이드)

    notifyListeners();

    try {
      await repository.deleteSchdule(id: id); // 삭제 실행함수 실행
    } catch (e) {
      //삭제 실패 시 캐시 롤백하기
      cache.update(
        date,
          (value) => [...value, targetSchedule]..sort(
              (a, b) => a.startTime.compareTo(
                b.startTime,
              ),
          ),
      );
    }
    notifyListeners();
  }

  // selectDate 변경하는 코드
  void changeSelectedDate({
    required DateTime date,
}) {
    selectedDate = date; // 현재 선택된 날짜를 매개변수로 입력받는 날짜로 변경
    notifyListeners();
  }

}//class