import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTile extends StatelessWidget {
  var text1;
  var text2;

  CustomTile({this.text1, this.text2});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height =  MediaQuery.of(context).size.height;
    return Container(
      color: CustomizedColors.customeTextColor,
      child: Row(
        children: <Widget>[
          Container(
            color: CustomizedColors.customeTextColor,
            width: width*0.35,
            height: height*0.08,
            child: Center(
                child: Text(
              text1,
              style: TextStyle(
                  color: CustomizedColors.customeColor,
                  fontWeight: FontWeight.bold),
            )),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(text2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
