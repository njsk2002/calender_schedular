import 'package:calendar_schedular/database/drift_database.dart';
import 'package:calendar_schedular/provider/schedule_provider.dart';
import 'package:calendar_schedular/repository/schedule_repository.dart';
import 'package:calendar_schedular/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';


void main() async{
  //플러터 프레임워크가 준비될때 까지 대기
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(); //init 패키지 초기화 (다국어화)

  final database = LocalDatabase(); // 데이터베이스 생성

  GetIt.I.registerSingleton<LocalDatabase>(database);

  final repository = ScheduleRepository();
  final scheduleProvider = ScheduleProvider(repository: repository);

  runApp(
    ChangeNotifierProvider( // Provider 하위위젯에 제공하기
        create: (_) => scheduleProvider,
        child: MaterialApp(
          home: HomeScreen(),
   ),
  ),
  );
}//class

