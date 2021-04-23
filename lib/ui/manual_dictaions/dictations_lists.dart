import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictations/play_dictations.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_all_manual_dictation_model.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/dictation_services.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/play_audio_services.dart';
import 'package:YOURDRS_FlutterAPP/ui/patient_dictation/play_audio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GetMyManualDictations extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GetMyManualDictationsState();
  }
}

class GetMyManualDictationsState extends State<GetMyManualDictations> {
  /// Declaring variables
  bool _hasMore;
  int _pageNumber;
  bool _error;
  bool _loading;
  bool isNetAvailable;
  final int _defaultDataPerPageCount = 20;
  List<AudioDictations> _audioDictates;
  int thresholdValue = 0;
  var filePath;

  /// initState
  @override
  void initState() {
    super.initState();
    _hasMore = true;
    _pageNumber = 1;
    _error = false;
    _loading = true;
    _audioDictates = [];
  }

  /// Creating an object for GetAllMyManualDictationApi
  AllMyManualDictations apiServices = AllMyManualDictations();

  /// Calling the Service file
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    GetAllMyManualDictation allMyManualDictations =
        await apiServices.getMyManualDictations(_pageNumber);
    if (!mounted) return;
    setState(() {
      _hasMore = allMyManualDictations.audioDictations?.length ==
          _defaultDataPerPageCount;
      _loading = false;
      _pageNumber = _pageNumber + 1;
      _audioDictates.addAll(allMyManualDictations?.audioDictations);
    });
  }

  /// Show Loading Dialog Progresses when data is loading
  Future<void> showLoadingDialog(BuildContext context, String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: SimpleDialog(
            backgroundColor: Colors.white,
            children: <Widget>[
              Center(
                child: Row(
                  children: [
                    SizedBox(
                      width: 25,
                    ),
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation(CustomizedColors.primaryColor),
                    ),
                    SizedBox(
                      width: 35,
                    ),
                    Text(msg,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  /// used to get the recording from the server
  getRecordings(String fileName, String displayFileName) async {
    Directory appDocDirectory;
    //platform checking conditions
    if (Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }
    String dir = appDocDirectory.path;
    String fileExists = "$dir/" + "$fileName";
    if (File(fileExists).existsSync()) {
      filePath = fileExists;
      setState(() {
        isNetAvailable = true;
      });
    } else {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        setState(() {
          isNetAvailable = true;
        });
        PlayAllAudioDictations apiServices1 = PlayAllAudioDictations();
        PlayDictations playDictations =
            await apiServices1.getDictationsPlayAudio(fileName);
        var getRecordings = playDictations.fileName;
        http.Response response = await http.get('$getRecordings');
        var _base64 = base64Encode(response.bodyBytes);
        Uint8List bytes = base64.decode(_base64);
        File file = File("$dir/" + '$displayFileName' + ".mp4");
        await file.writeAsBytes(bytes);
        filePath = file.path;
      } else {
        setState(() {
          isNetAvailable = false;
        });
      }
    }
  }

  /// build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomizedColors.background,
      body: getBody(),
    );
  }

  /// CircularProgress when data is loading
  Widget _circularProgress() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(CustomizedColors.primaryColor),
        ),
      ),
    );
  }

  /// display message if any error while calling api
  Widget _errorWidget() {
    return Center(
      child: InkWell(
        onTap: () {
          setState(
            () {
              _loading = true;
              _error = false;
              didChangeDependencies();
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset(AppImages.noConnection),
              Text(AppStrings.noConnection),
              Text(AppStrings.errorLoading),
            ],
          ),
        ),
      ),
    );
  }

  /// body Widget
  // ignore: missing_return
  Widget getBody() {
    if (_audioDictates?.isEmpty ?? false) {
      if (_loading) {
        return _circularProgress();
      } else if (_error) {
        return _errorWidget();
      }
    } else {
      return _listViewContainer();
    }
  }

  /// Widget for ListView builder
  Widget _listViewContainer() {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 15),
      child: AnimationLimiter(
        child: ListView.builder(
            itemCount: _audioDictates.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _audioDictates.length - thresholdValue) {
                didChangeDependencies();
              }
              if (index == _audioDictates.length) {
                if (_error) {
                  return _errorWidget();
                } else {
                  return _circularProgress();
                }
              }
              return _cardAnimationWidget(index);
            }),
      ),
    );
  }

  /// Animation for Card
  Widget _cardAnimationWidget(index) {
    // final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final AudioDictations audioDictations = _audioDictates[index];
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            padding: const EdgeInsets.only(bottom: 2),
            child: Card(
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.only(
                    left: 15, right: 10, top: 10, bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: width * 0.55,
                      child: Text(
                        audioDictations.displayFileName,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                      ),
                      padding: const EdgeInsets.only(right: 50),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Uploaded",
                                style: TextStyle(color: Colors.green),
                              ),
                              SizedBox(width: 20),
                              Icon(
                                Icons.cloud_done_outlined,
                                color: CustomizedColors.primaryColor,
                              ),
                            ],
                          ),
                          SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Center(
                                    child: Icon(
                                      Icons.description,
                                      color: CustomizedColors.primaryColor,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _conditionCheckBottomSheet(index);
                                  },
                                  icon: Center(
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: CustomizedColors.primaryColor,
                                      size: 35,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// check condition for bottom sheet
  // ignore: missing_return
  Widget _conditionCheckBottomSheet(index) {
    final AudioDictations audioDictations = _audioDictates[index];
    if (audioDictations.fileName.isEmpty ||
        audioDictations.fileName == null ||
        audioDictations.displayFileName == null ||
        audioDictations.displayFileName.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.noAudioRecordings),
          actions: [
            // ignore: deprecated_member_use
            FlatButton(
              child: Text(AppStrings.closeDialog),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      showLoadingDialog(context, AppStrings.loading);
      getRecordings(audioDictations.fileName, audioDictations.displayFileName);
      Navigator.of(this.context, rootNavigator: true).pop();
      if (isNetAvailable = true) {
        _bottomSheet(index);
      } else {
        AppToast().showToast(AppStrings.networkNotConnected);
      }
    }
  }

  /// UI for bottom sheet
  void _bottomSheet(index) async {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final AudioDictations audioDictations = _audioDictates[index];
    return await showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              )),
          height: 340,
          child: Column(
            children: [
              PlayAudio(
                displayFileName: audioDictations.displayFileName,
                filePath: filePath,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Card(
                    color: CustomizedColors.primaryColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      width: width * 0.3,
                      height: height * 0.065,
                      child: Center(
                        child: Text(
                          "Ok",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CustomizedColors.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
