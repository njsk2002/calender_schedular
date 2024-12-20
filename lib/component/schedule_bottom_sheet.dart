
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

  @override
  Widget build(BuildContext context) {
    //키보드 높이 가져오기
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
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
                        ),
                    ),
                    const SizedBox(width: 16.0,),
                    Expanded(
                        child: CustomTextField(
                            label: '종료 시간',
                            isTime: true
                        ),
                    ),
                    ],
                ),
                SizedBox(height: 8.0,),
                Expanded(
                    child: CustomTextField(
                        label: '내용',
                        isTime: false,
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
    );
  }

  void onSavePressed(){

  }
}//class