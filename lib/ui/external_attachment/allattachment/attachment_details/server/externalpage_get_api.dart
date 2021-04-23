import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_all_external_attachments_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_external_document_details.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_external_photos.dart';
import 'package:YOURDRS_FlutterAPP/network/services/external_attachment/all_external_attachment_service.dart';
import 'package:YOURDRS_FlutterAPP/ui/external_attachment/allattachment/attachment_details/local/allattachment_screen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'externalattachment_server.dart';


class GetMyAttachments extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GetMyAttachmentsState();
  }
}

class GetMyAttachmentsState extends State<GetMyAttachments> {
  /// Declaring variables
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  bool _hasMore;
  int _pageNumber;
  bool _error;
  bool _loading;
  int _defaultDataPerPageCount = 20;
  List<ExternalDocumentList> _externalAttachments;
  int thresholdValue = 0;
  bool isInternetAvailable = true;
  int externalAttachmentId;
  String imageName;
  String displayFileName;
  String attachmentName;
  bool hasData = false;
  List imageList = [];

  /// Creating an object of class
  AppToast appToast = AppToast();
  AllMyExternalAttachments apiServices = AllMyExternalAttachments();
  GetExternalDocumentDetailsService apiService2 =
      GetExternalDocumentDetailsService();
  GetExternalPhotosService apiService3 = GetExternalPhotosService();

  /// Calling Service file
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    GetAllExternalAttachments allMyExternalAttachments =
        await apiServices.getMyAllExternalAttachemnts(_pageNumber);
    if (!mounted) return;
    setState(() {
      _hasMore = allMyExternalAttachments.externalDocumentList?.length ==
          _defaultDataPerPageCount;
      _loading = false;
      _pageNumber = _pageNumber + 1;
      _externalAttachments
          .addAll(allMyExternalAttachments?.externalDocumentList);
    });
  }

  /// Show Loading Dialog Progresses when data is loading
  Future<void> showLoadingDialog(BuildContext context, GlobalKey key) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new WillPopScope(
          onWillPop: () async => false,
          child: SimpleDialog(
            key: key,
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
                    Text(
                      AppStrings.loading,
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

  /// Check Internet Connection
  void checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        isInternetAvailable = true;
      });
    } else {
      setState(() {
        isInternetAvailable = false;
      });
      appToast.showToast(AppStrings.no_internet);
    }
  }

  /// initState
  @override
  void initState() {
    super.initState();
    _hasMore = true;
    _pageNumber = 1;
    _error = false;
    _loading = true;
    _externalAttachments = [];
    checkInternet();
  }

  /// app build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomizedColors.background,
      body: checkInternetConnection(),
    );
  }

  /// checking internet connection if connection available show api data
  /// else show local data
  Widget checkInternetConnection() {
    return isInternetAvailable
        ? Container(
            child: apiData(),
          )
        : Container(
            child: Allattachmentlocal(),
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

  /// condition for checking if api data is empty
  // ignore: missing_return
  Widget apiData() {
    if (_externalAttachments?.isEmpty ?? false) {
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
          itemCount: _externalAttachments.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _externalAttachments.length - thresholdValue) {
              didChangeDependencies();
            }
            if (index == _externalAttachments.length) {
              if (_error) {
                return _errorWidget();
              } else {
                return _circularProgress();
              }
            }
            return _cardAnimationWidget(index);
          },
        ),
      ),
    );
  }

  /// Animation for Card
  Widget _cardAnimationWidget(index) {
    // final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final ExternalDocumentList externalDocuments = _externalAttachments[index];
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
                        externalDocuments.displayFileName,
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
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(width: 70),
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _openAttachmentDetails(index);
                                  },
                                  icon: Center(
                                    child: Icon(
                                      Icons.description,
                                      color: CustomizedColors.primaryColor,
                                      size: 30,
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

  /// on click of button open the attachmentsDetails
  void _openAttachmentDetails(index) async {
    showLoadingDialog(context, _keyLoader);
    final ExternalDocumentList externalDocuments = _externalAttachments[index];
    //external attachment details api
    setState(() {
      externalAttachmentId = externalDocuments.externalAttachmentId;
      externalAttachmentId = externalDocuments.externalAttachmentId;
      displayFileName = externalDocuments.displayFileName;
    });
    //external attachment details api
    GetExternalDocumentDetails getExternalDocumentDetails =
        await apiService2.getExternalDocumentDetails(externalAttachmentId);

    for (var i = 0; i < getExternalDocumentDetails.attachments.length; i++) {
      getExternalDocumentDetails.attachments.length != 0
          ? attachmentName = getExternalDocumentDetails.attachments[i].name
          : attachmentName = "";
      getExternalDocumentDetails.attachments.length != 0
          ? imageName = getExternalDocumentDetails.attachments[i].name
          : imageName = "";
      imageList.add({"image_path": imageName});
    }
    //external attachment photos api
    GetExternalPhotos getExternalPhotos =
        await apiService3.getExternalPhotos(imageName);

    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExternalAttachmentServer(
          displayFilename: displayFileName ?? "",
          externalAttachmentId: externalAttachmentId ?? "",
          practiceName: getExternalDocumentDetails.practiceName ?? "",
          locationName: getExternalDocumentDetails.locationName ?? "",
          externalDocumentTypeName:
              getExternalDocumentDetails.externalDocumentTypeName ?? "",
          providerName: getExternalDocumentDetails.providerName ?? "",
          patientFirstName: getExternalDocumentDetails.patientFirstName ?? "",
          dob: getExternalDocumentDetails.dob ?? "",
          isEmergencyAddon: getExternalDocumentDetails.isEmergencyAddOn ?? "",
          description: getExternalDocumentDetails.description ?? "",
          attachmentName: attachmentName,
          filename: getExternalPhotos.fileName ?? "",
        ),
      ),
    );
  }
}
