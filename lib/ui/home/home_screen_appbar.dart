import 'dart:async';
import 'package:YOURDRS_FlutterAPP/blocs/home/patient_bloc.dart';
import 'package:YOURDRS_FlutterAPP/blocs/home/patient_bloc_event.dart';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
import 'package:YOURDRS_FlutterAPP/common/app_pop_menu.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/widget/date_range_picker.dart';
import 'package:YOURDRS_FlutterAPP/widget/input_fields/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var displayName = "";
  var profilePic = "";
 int initialValue =1;
  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      displayName = (prefs.getString(Keys.displayName) ?? '');
      profilePic = (prefs.getString(Keys.displayPic) ?? '');
    });
  }
  void initState() {
    super.initState();
    _loadData();}
  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        CircleAvatar(
          radius: 18,
          foregroundColor: Colors.green,
          child: ClipOval(
            child: profilePic == ""
                ? Image.asset(
              AppImages.defaultImg,
              width: 30,
              height: 25,
              fit: BoxFit.cover,
            )
                : Image.network(
              profilePic,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 13,),
        Text(
          AppStrings.welcome,
          style: GoogleFonts.montserrat(
            color: CustomizedColors.textColor, fontSize: 16.0,
          ),
        ),
        SizedBox(
          width:8,
        ),
        Expanded(
          child: Text(
            displayName ?? "",
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
                color: CustomizedColors.textColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
//display the search result
class Search_Fail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Padding(
              padding:
              EdgeInsets.only(top: 75)),
          Center(
            child: Text(
              AppStrings.noresultsfoundrelatedsearch,
              style: GoogleFonts.montserrat(
                  fontSize: 18.0,
                  fontWeight:
                  FontWeight.bold,
                  color: CustomizedColors
                      .noAppointment),
            ),
          )
        ],
      ),
    );
  }
}
class Popupmenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: EdgeInsets.only(right: 10.0, bottom: 52.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
            backgroundColor: CustomizedColors.primaryColor,
            onPressed: () {},
            tooltip: 'Increment',
            child: Pop(
              //  initialValue: 1,
            )),
      ),
    );
  }
}


