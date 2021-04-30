import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/searchable_dropdown.dart';
import 'package:flutter/material.dart';
// import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'dart:async';
import 'dart:convert';
import '../../network/models/home/dictation.dart';

class Dictation extends StatefulWidget {
  final onTapOfDictation;
  Dictation({@required this.onTapOfDictation});

  @override
  _DictationSearchState createState() => _DictationSearchState();
}

class _DictationSearchState extends State<Dictation> {
  bool searching = false;
  DictationStatus _currentSelectedValue;
  final String url = "https://jsonplaceholder.typicode.com/users";

  List<DictationStatus> data = List(); //edited line

// --------> get and decode the API data <-----------
  Future<String> getDictation() async {
    String jsonData = await DefaultAssetBundle.of(context)
        .loadString("assets/json/appointment.json");
    final jsonResult = json.decode(jsonData);
    data = List<DictationStatus>.from(
        jsonResult.map((x) => DictationStatus.fromJson(x)));

    if (mounted) {
      setState(() {});
    }
  }

//// ---> calling initState() method <----
  @override
  void initState() {
    super.initState();
    this.getDictation();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width*0.70,

// ----------> displaying Dictation list from API in SearchableDropdown <--------
      child: SearchableDropdown.single(
        displayClearIcon: false,
        hint: Text(AppStrings.dictationsearchtxt),
        // label: Text(
        //   AppStrings.dictationhinttxt,
        //   style: TextStyle(
        //       fontSize: 16,
        //       fontWeight: FontWeight.bold,
        //       color: CustomizedColors.dropdowntxtcolor),
        // ),
// ----------> displaying the the data which stored in data of list type <--------
        items: data.map((item) {
          return DropdownMenuItem<DictationStatus>(
            child: new Text(item.dictationstatus),
            value: item,
          );
        }).toList(),
        value: _currentSelectedValue,
        underline: Container(),
        isExpanded: true,
        searchHint: new Text(AppStrings.dictationsearchtxt,
            style: new TextStyle(fontSize: 20)),
// ----------> called when a new item is selected <--------
        onChanged: (value) {
          setState(
            () {
              _currentSelectedValue = value;
            },
          );
          widget.onTapOfDictation(value);
        },
      ),
    );
  }
}
