
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/helper/db_helper.dart';
import 'package:YOURDRS_FlutterAPP/network/models/external_dictations/external_databse_model.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/external_dictation_attacment_model.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/network/services/dictation/extrenalattachmnent_postapi.dart';
import 'package:YOURDRS_FlutterAPP/network/services/external_attachment/external_localtoserver_postapi.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'externalattachment_details.dart';
class Allattachmentlocal extends StatefulWidget {
  @override
  _AllattachmentState createState() => _AllattachmentState();
}

class _AllattachmentState extends State<Allattachmentlocal> {

  //----------chekcing internet connection
  List<ExternalAttachmentList> attachments = [];
  int attachmentId;
  String displayName;
  int uploadedToServer;
//-----------------local data base variables fetching
  int practiceId;
 int LocationId;
 int providerId1;
 String firstname;
  String lastname;
  String _dateOfbirthController;
  var memberId;
  int documenttypeId;
  var emergencyAddOn;
  var Description;
 // dynamic photoListOfGallery;
  var statusCode;
  bool uploadSuccess=false;
  ExternalAttachmentDataApi apiAttachmentPostServices = ExternalAttachmentDataApi();

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      memberId = (prefs.getString(Keys.memberId) ?? '');
    });
  }
@override
  void initState() {
    // TODO: implement initState
  _loadData();
    super.initState();
  }
  // List<PhotoList>
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
          child:  FutureBuilder(
              future: DatabaseHelper.db.getAllExtrenalAttachmentList(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                print(snapshot.hasData);
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {

                  attachments = snapshot.data as List<ExternalAttachmentList>;
                  return
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: attachments.length,
                        itemBuilder: (BuildContext context, int index) {
                          attachmentId =attachments[index].id;
//------------------------------local data o store the server
                          uploadedToServer=attachments[index].uploadedtoserver;
                          practiceId=attachments[index].practiceid;
                          LocationId=attachments[index].locationid;
                          providerId1=attachments[index].providerid;
                          firstname=attachments[index].patientfirstname;
                          lastname=attachments[index].patientlastname;
                          _dateOfbirthController=attachments[index].patientdob;
                          documenttypeId=attachments[index].externaldocumenttypeid;
                          emergencyAddOn=attachments[index].isemergencyaddon;
                          Description=attachments[index].description;

                          return InkWell(
                            onTap: () async {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Externalattachment_data(
                                      attachmentId: attachments[index].id,
                                      displayfilename:
                                      attachments[index].displayfilename,
                                      practicename: attachments[index].practicename,
                                      locationname: attachments[index].locationname,
                                      externaldocumenttype:
                                      attachments[index].externaldocumenttype,
                                      providername: attachments[index].providername,
                                      patientfirstname:
                                      attachments[index].patientfirstname,
                                      patientdob: attachments[index].patientdob,
                                      isemergencyaddon:
                                      attachments[index].isemergencyaddon,
                                      description: attachments[index].description,
                                      uploadedtoserver: attachments[index].uploadedtoserver,
                                    )),
                              );
                            },
                            child:
                            Container(
                              child: Card(
                                child: ListTile(
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(padding: new EdgeInsets.all(3.0)),

                                      Container(
                                        width: 320,
                                        child: Text(
                                          "${attachments[index].displayfilename}",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                                      ),
                                    ],
                                  ),
                                    trailing: uploadedToServer==0?IconButton(
                                      icon: Icon(Icons.cloud_done, size: 34,color: Colors.black54,),
                                      onPressed: () async{
                                        //------------passing local data to server
                                        try{
                                          if (emergencyAddOn == 0) {
                                            emergencyAddOn = false;
                                          } else {
                                            emergencyAddOn = true;
                                          }
                                          SaveExternalDictationOrAttachment saveDictationAttachments =
                                          await apiAttachmentPostServices.postApiServiceMethod(
                                            practiceId??null,//selectedPracticeId
                                            LocationId??null,//locationId
                                            providerId1??null,//providerId
                                            firstname,//patientFname
                                            lastname,//patientLname
                                            _dateOfbirthController,//patientDob
                                            memberId,
                                            documenttypeId,
                                            emergencyAddOn,
                                            Description,
                                            null,//convertedImg,
                                            null,//name
                                            null,//attachmentType
                                          );
                                          statusCode = saveDictationAttachments?.header?.statusCode;
                                          if(statusCode == "200"){
                                            setState(() {
                                              this.uploadedToServer == 1;
                                            });

                                          }else{
                                            setState(() {
                                              this.uploadedToServer == 0;
                                            });

                                          }
                                          //printing status code
                                          print("status!!!!!!!!!!!!!!!!!!!!!!!!!! $statusCode");
                                          print("memberID:: " + memberId);
                                        }
                                        catch (e) {
                                          print('SaveAttachmentDictation exception ${e.toString()}');
                                        }
                                      },
                                    ):IconButton(
                                      icon: Icon(Icons.cloud_done, size: 34,color:CustomizedColors.primaryColor,),
                                      onPressed: () {

                                      },
                                    ),
                                ),
                              ),
                            ),
                          );
                        }
                    );
                }
              }
          )
      );
  }
}

