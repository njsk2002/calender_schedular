

import 'package:calendar_schedular/model/schedule_model.dart';
import 'package:calendar_schedular/repository/auth_repository.dart';
import 'package:calendar_schedular/repository/schedule_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class ScheduleProvider extends ChangeNotifier{
  final AuthRepository authRepository;
  final ScheduleRepository scheduleRepository; //API 요청 로직을 담은 클래스

  String? accessToken;
  String? refreshToken;

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  Map<DateTime, List<ScheduleModel>> cache = {}; //일정 정보를 저장해둘 변수

  ScheduleProvider({
    required this.scheduleRepository,
    required this.authRepository,
}) : super() {
    getSchedules(date: selectedDate);
  }

  void getSchedules ({
    required DateTime date,
  }) async{
    final resp = await scheduleRepository.getSchedules(
        date: date,
        //로그인을 해야 사용자와 관련된 일정 정보를 가져오는 getSchedules()함수를
        //실행할수 있는 화면으로 이동함으로 !를  붙여서 accessToken이
        //null이 아님을 명시함.
        accessToken: accessToken!);//get 메서드보내기
    
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
      final savedSchedule = await scheduleRepository.createSchedule(
          schedule: schedule,
          accessToken: accessToken!,
      );

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
      await scheduleRepository.deleteSchdule(
          id: id,
          accessToken: accessToken!,
      ); // 삭제 실행함수 실행
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

  ///////////////////////////////////////////////////////////////////
  ////////////  향후 AuthProvider로 변경 ////////////////////////////
  //////////////////////////////////////////////////////////////////

  //토큰 관리
  updateTokens({
    String? refreshToken,
    String? accessToken,
}) {
    //refreshToken이 입력됐을 경우 refreshToken 업데이트
    if (refreshToken != null){
      this.refreshToken = refreshToken;
    }
    //accessToken이 입력되었을 경우 accessToken 업데이트
    if (accessToken != null){
      this.accessToken = accessToken;
    }

    notifyListeners();
  }

  //회원가입
 Future<void> register({
    required String email,
    required String password,
}) async {
    // AuthRepository에 미리 구현해둔 register() 함수를 실행
   final resp = await authRepository.register(
       email: email,
       password: password
   );

   //반환받는 토큰을 기반으로 토큰 프로퍼티를 업그레이드
   updateTokens(
     refreshToken: resp.refreshToken,
     accessToken: resp.accessToken,
   );
 }

 //로그인

Future<void> login({
    required String email,
    required String password,
}) async {
    final resp = await authRepository.login(
        email: email,
        password: password
    );
    updateTokens(
      refreshToken: resp.refreshToken,
      accessToken: resp.accessToken,
    );
}

//로그 아웃
logout() {
  //refreshToken과 accessToken을 null로 업데이트해서 logout상태로 전환
  refreshToken = null;
  accessToken = null;

   //로그 아웃과 동시에 일정 정보 캐시도 모두 삭제
  cache = {};
  notifyListeners();

}

// refreshToken과 accessToken 재발급
rotateToken({
    required String refreshToken,
    required bool isRefreshToken,
}) async {
    // isRefreshToken이 true일 경우 refreshToken 재발급
    // false 일 경우 accessToken 재발급
  if(isRefreshToken){
    final token = await authRepository.rotateRefreshToken(refreshToken: refreshToken);

    this.refreshToken = token;
  } else{
    final token = await authRepository.rotateAccessToken(refreshToken: refreshToken);
    accessToken = token;
  }

  notifyListeners();
}

}//class