import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_external_document_details.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/get_external_photos.dart';
import 'package:YOURDRS_FlutterAPP/network/services/external_attachment/all_external_attachment_service.dart';
import 'package:YOURDRS_FlutterAPP/ui/external_attachment/allattachment/attachment_details/external_component.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ExternalAttachmentServer extends StatefulWidget {
  static const String routeName = '/ExternalAttachments';
  var displayFilename;
  var practiceName;
  var locationName;
  var externalDocumentTypeName;
  var providerName;
  var patientFirstName;
  var dob;
  var isEmergencyAddon;
  var description;
  var filename;
  var attachmentName;
  var externalAttachmentId;

  ExternalAttachmentServer(
      {this.displayFilename,
      this.practiceName,
      this.locationName,
      this.externalDocumentTypeName,
      this.providerName,
      this.patientFirstName,
      this.dob,
      this.isEmergencyAddon,
      this.description,
      this.filename,
      this.attachmentName,
      this.externalAttachmentId});

  @override
  ExternalAttachmentServerState createState() =>
      ExternalAttachmentServerState();
}

class ExternalAttachmentServerState extends State<ExternalAttachmentServer> {
  List<Attachments> _list = [];
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  /// Creating an object of class
  AllMyExternalAttachments apiServices = AllMyExternalAttachments();
  GetExternalDocumentDetailsService apiService2 =
      GetExternalDocumentDetailsService();
  GetExternalPhotosService apiService3 = GetExternalPhotosService();

  @override
  void initState() {
    super.initState();
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

  /// Calling an api
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    GetExternalDocumentDetails photoListArray = await apiService2
        .getExternalDocumentDetails(widget.externalAttachmentId);
    _list = photoListArray.attachments;
    if (mounted) {
      setState(() {});
    }
  }

  /// build Method
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CustomizedColors.background,
      appBar: AppBar(
        backgroundColor: CustomizedColors.ExtAppbarColor,
        toolbarHeight: 70,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            RouteGenerator.navigatorKey.currentState
                .pushReplacementNamed(ExternalAttachmentServer.routeName);
          },
        ),
        title: Container(
          child: Text(
            widget.displayFilename ?? "",
            style: TextStyle(fontSize: 18),
            overflow: TextOverflow.fade,
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CustomizedColors.primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              AppStrings.casedetails_text,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: CustomizedColors.customeColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Divider(
                              color: CustomizedColors.primaryColor,
                              height: 1,
                              thickness: 5,
                            ),
                          ),
                          CustomTile(
                              text1: AppStrings.practice_text,
                              text2: widget.practiceName ?? ""),
                          Divider(
                            color: CustomizedColors.primaryColor,
                            height: 1,
                            thickness: 0.8,
                          ),
                          CustomTile(
                              text1: AppStrings.location_text,
                              text2: widget.locationName ?? ""),
                          Divider(
                            color: CustomizedColors.primaryColor,
                            height: 1,
                            thickness: 0.8,
                          ),
                          CustomTile(
                              text1: AppStrings.doc_text,
                              text2: widget.externalDocumentTypeName ?? ""),
                          Divider(
                            color: CustomizedColors.primaryColor,
                            height: 1,
                            thickness: 0.8,
                          ),
                          CustomTile(
                              text1: AppStrings.provider_text,
                              text2: widget.providerName ?? ""),
                          Divider(
                            color: CustomizedColors.primaryColor,
                            height: 1,
                            thickness: 0.8,
                          ),
                          CustomTile(
                              text1: AppStrings.name_text,
                              text2: widget.patientFirstName ?? ""),
                          Divider(
                            color: CustomizedColors.primaryColor,
                            height: 1,
                            thickness: 0.4,
                          ),
                          CustomTile(
                              text1: AppStrings.dob_text,
                              text2: widget.dob ?? ""),
                          Divider(
                            color: CustomizedColors.primaryColor,
                            height: 1,
                            thickness: 0.8,
                          ),
                          CustomTile(
                              text1: AppStrings.isemergency_text,
                              text2: widget.isEmergencyAddon.toString()),
                          Divider(
                            color: CustomizedColors.primaryColor,
                            height: 1,
                            thickness: 0.8,
                          ),
                          CustomTile(
                              text1: AppStrings.description_text,
                              text2: widget.description ?? ""),
                          Divider(
                            color: CustomizedColors.primaryColor,
                            height: 1,
                            thickness: 0.8,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, bottom: 15, top: 30),
                            child: Text(
                              AppStrings.uploadedattachments_text,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: CustomizedColors.customeColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10),
                            child: Divider(
                              color: CustomizedColors.primaryColor,
                              height: 1,
                              thickness: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: width,
                      height: height * 0.3,
                      child: _list != null || _list.isNotEmpty
                          ? ListView.builder(
                              primary: false,
                              scrollDirection: Axis.vertical,
                              itemCount: _list.length,
                              itemBuilder: (context, index) {
                                Attachments item = _list[index];
                                return imageWidget(item);
                              },
                            )
                          : Container(
                              child: Center(
                                child: Text(
                                  AppStrings.noimagefound_text,
                                  style: TextStyle(
                                    color: CustomizedColors.actionsheettext,
                                    fontFamily: AppFonts.regular,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget imageWidget(item) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 30),
                width: width * 0.65,
                height: height * 0.08,
                child: Center(
                  child: Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),
              ),
              Container(
                width: width * 0.20,
                height: height * 0.06,
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextButton(
                    child: Text(
                      "View",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _showImage(item);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: CustomizedColors.primaryColor,
          height: 1,
          thickness: 0.8,
        ),
      ],
    );
  }

  void _showImage(item) async {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    showLoadingDialog(context, _keyLoader);
    //get external attachments photos api
    GetExternalPhotos getExternalPhotos =
        await apiService3.getExternalPhotos(item.name);
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          width: width,
          height: height * 0.7,
          child: Image.network(
            getExternalPhotos.fileName,
            fit: BoxFit.fill,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation(CustomizedColors.primaryColor),
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
