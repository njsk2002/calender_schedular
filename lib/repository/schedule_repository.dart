

import 'dart:async';
import 'dart:io';

import 'package:calendar_schedular/model/schedule_model.dart';
import 'package:dio/dio.dart';

class ScheduleRepository{
  final _dio = Dio();
  //final _targetUrl = 'http://${Platform.isAndroid ? '10.0.2.2' : 'localhost'}:3000/schedule';
  //final _targetUrl = 'http://${Platform.isAndroid ? '127.0.0.1' : 'localhost'}:5000/schedule/calendar_data';
   //final _targetUrl = 'http://${Platform.isAndroid ? '10.0.2.2' : '127.0.0.1'}:5000/schedule/calendar_data';
  final _targetUrl = 'http://${Platform.isAndroid ? '192.168.0.16' : '127.0.0.1'}:5000/schedule/calendar_data';

  //안드로이드에서는 10.0.2.2가 localhost에 해당함

  Future<List<ScheduleModel>> getSchedules({
    required String accessToken,
    required DateTime date,

}) async{
    final resp = await _dio.get(
      _targetUrl,
      queryParameters: { // Query 매개 변수
        'date':
            '${date.year}${date.month.toString().padLeft(2,
                '0')}${date.day.toString().padLeft(2,'0')}',
      },
      //요청을 보낼때 헤더에 액세스토큰을 포함해서 보냄
      options: Options(
        headers: {
          'authorization' : 'Bearer $accessToken',
        },
      ),
    );

    return resp.data // 모델 인스턴스로 데이터 매핑하기
    .map<ScheduleModel>(
        (x) => ScheduleModel.fromJson(
            json: x
        ),
    )
        .toList();
  }

  Future<String> createSchedule({
    required String accessToken,
    required ScheduleModel schedule,
}) async {
    final json = schedule.toJson(); // JSON으로 변환
    final resp = await _dio.post(
        _targetUrl,
        data: json,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'authorization' : 'Bearer $accessToken',
          },
        ),
    );

    return resp.data?['id'];
  }


 Future<String> deleteSchdule({
    required String accessToken,
    required String id,
}) async {
    final resp = await _dio.delete(_targetUrl, data :{
      'id' : id,
    },
      options: Options(
        headers: {
          'authorization' : 'Bearer $accessToken',
        }
      )
    );
    return resp.data?['id']; // 삭제된 id값 반환
 }


}//class
