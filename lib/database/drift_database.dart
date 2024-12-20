import 'dart:io';

import 'package:calendar_schedular/model/schedule.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

//private값까지 불러올수 있음
part 'drift_database.g.dart'; // part 파일 지정

@DriftDatabase(//사용할 테이블 등록
 tables:[
   Schedules,
 ],
 )

class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  Stream<List<Schedule>> watchSchedules(DateTime date) =>
      //데이터를 조회하고, 변화감지
  (select(schedules)..where((tbl) => tbl.date.equals(date))).watch();


//watchSchedules() 함수 아래에 작성
Future<int> createSchedule(SchedulesCompanion data) =>
    into(schedules).insert(data);

Future<int> removeSchedule(int id) =>
    (delete(schedules)..where((tbl) => tbl.id.equals(id))).go();

  @override
  // TODO: implement schemaVersion
  int get schemaVersion => 1;


} //code Generation으로 생성할 클래스 상속

LazyDatabase _openConnection(){
  return LazyDatabase(() async{
    // 데이터베이스 파일 저장할 폴더
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}