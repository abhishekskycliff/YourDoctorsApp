import 'dart:io';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_log_helper.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class ViewImages extends StatefulWidget {
  static const String routeName = '/ViewImages';


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ViewImagesState();
  }
}

class ViewImagesState extends State<ViewImages> {
  bool isLoadingPath = false;
  int gIndex;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final List file=ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          title: Text("Uploaded Images"),
          backgroundColor: CustomizedColors.primaryColor,
        ),
        body: Container(
            child: ListView(children: [
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: CustomizedColors.homeSubtitleColor,
              ),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                  bottomRight: Radius.zero),
            ),
            child: Builder(
                builder: (BuildContext context) => isLoadingPath
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: const CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:file.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            child: Container(
                              margin: const EdgeInsets.all(10.0),
                              height: 130,
                              width: 150,
                              color: CustomizedColors.homeSubtitleColor,
                              child: Image.file(
                               file[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                gIndex = index;
                              });
                            },
                          );
                        },
                      )),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width,
            margin:
                const EdgeInsets.only(left: 0.0, top: 30, right: 0, bottom: 0),
            child: Image.file(
             file[(gIndex == null ? 0 : gIndex)],
              fit: BoxFit.contain,
            ),
          )
        ])));
  }
}
