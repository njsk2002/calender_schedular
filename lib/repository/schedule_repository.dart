

import 'dart:async';
import 'dart:io';

import 'package:calendar_schedular/model/schedule_model.dart';
import 'package:dio/dio.dart';

class ScheduleRepository{
  final _dio = Dio();
  //final _targetUrl = 'http://${Platform.isAndroid ? '10.0.2.2' : 'localhost'}:3000/schedule';
  //final _targetUrl = 'http://${Platform.isAndroid ? '127.0.0.1' : 'localhost'}:5000/schedule/calendar_data';
  final _targetUrl = 'http://${Platform.isAndroid ? '10.0.2.2' : '127.0.0.1'}:5000/schedule/calendar_data';

  //안드로이드에서는 10.0.2.2가 localhost에 해당함

  Future<List<ScheduleModel>> getSchedules({
    required DateTime date,

}) async{
    final resp = await _dio.get(
      _targetUrl,
      queryParameters: { // Query 매개 변수
        'date':
            '${date.year}${date.month.toString().padLeft(2,
                '0')}${date.day.toString().padLeft(2,'0')}',
      },
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
    required ScheduleModel schedule,
}) async {
    final json = schedule.toJson(); // JSON으로 변환
    final resp = await _dio.post(
        _targetUrl,
        data: json,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
    );

    return resp.data?['id'];
  }


 Future<String> deleteSchdule({
  required String id,
}) async {
    final resp = await _dio.delete(_targetUrl, data :{
      'id' : id,
    });
    return resp.data?['id']; // 삭제된 id값 반환
 }


}//class
