import 'package:calendar_schedular/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async{
  //플러터 프레임워크가 준비될때 까지 대기
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(); //init 패키지 초기화 (다국어화)
  runApp(
    MaterialApp(
    home: HomeScreen(),
   ),
  );
}

