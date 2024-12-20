
import 'package:calendar_schedular/component/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../const/colors.dart';

class ScheduleBottomSheet extends StatefulWidget{
  const ScheduleBottomSheet({Key? key}): super(key:key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();

}//CLASS

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet>{
  final GlobalKey<FormState> formkey = GlobalKey(); //폼키 설정

  int? startTime; // 시작 시간 저장 변수
  int? endTime; //종료 시간 저장 변수
  String? content;// 일정내용 저장 변수

  @override
  Widget build(BuildContext context) {
    //키보드 높이 가져오기
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Form(
      key: formkey, // 텍스트 필드를 한번에 관리할 수 있는 폼
      child: SafeArea( // Form을 조작할 키값
        child: Container(
          height: MediaQuery.of(context).size.height / 2 + bottomInset,
          //SafeArea 위젯에 화면의 반을 차지하는 흰색 Container 위젯을 하나 배치
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8, top:8 , bottom: bottomInset),
            child: Column(
              //시간 관련 텍스트 필드의 내용 관련 텍스트 필드 세로로 배치
              children: [
                Row(
                  // 시작시간, 종료시간 가로로 배치
                  children: [
                    Expanded(
                        child: CustomTextField(
                            label: '시작 시간',
                            isTime: true,
                            onSaved: (String? val) {
                              //저장이 실행되면 startTime 변수에 텍스트 필드값 저장
                              startTime = int.parse(val!);
                             },
                          validator: timeValidator,

                        ),
                    ),
                    const SizedBox(width: 16.0,),
                    Expanded(
                        child: CustomTextField(
                            label: '종료 시간',
                            isTime: true,
                            onSaved: (String? val) {
                              endTime = int.parse(val!);
                            },
                            validator: timeValidator,

                        ),
                    ),
                    ],
                ),
                SizedBox(height: 8.0,),
                Expanded(
                    child: CustomTextField(
                      label: '내용',
                      isTime: false,
                      onSaved: (String? val) {
                        content = val;
                      },
                      validator: contentValidator,
                    ),
                   ),
                SizedBox(
                  width : double.infinity,
                  child : ElevatedButton( // 저장버튼
                      onPressed: onSavePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR, // primary 대신 backgroundColor 사용
                      ),
                      child: Text('저장'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onSavePressed(){
    if(formkey.currentState!.validate()){ // 폼 검증하기
      formkey.currentState!.save(); //폼 저장하기

      print(startTime);
      print(endTime);
      print(content);
    }
  }

  String? timeValidator(String? val){ // 시간 검증 함수
    if (val == null){
      return '값을 입력하세요';
    }

    int? number;

    try {
      number = int.parse(val);
    }catch (e){
      return '숫자를 입력해주세요';
    }

    if (number < 0 || number > 24){
      return '0시부터 24시 사이를 입력해주세요';
    }

    return null;

  } // 시간값 검증

  String? contentValidator(String? val){ // 내용 검증 함수
    if(val == null || val.length == 0){
      return '값을 입력해주세요';
    }

    return null;

  }// 내용값 검증
}//class