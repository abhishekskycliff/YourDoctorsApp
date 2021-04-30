import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/network/services/schedules/appointment_service.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/document_type.dart';

class DocumentDropDown extends StatefulWidget {
  final onTapDocument;
  String selectedDocumentType;
  DocumentDropDown({@required this.onTapDocument, this.selectedDocumentType});
  @override
  _DocumentState createState() => _DocumentState();
}

class _DocumentState extends State<DocumentDropDown>
    with AutomaticKeepAliveClientMixin {
  bool asTabs = false;
  var _currSelectedDoc;
  //------------------service
  //Services apiServices =  Services();


  ExternalDocumentTypesList externalDocumentTypesList;
  //List<LocationList> _list=[];
  List data = List();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // Documenttype document = (await apiServices.getDocumenttype()) as Documenttype;
    // data = document.externalDocumentTypesList;
    //apiServices.getDocumenttype();
    var apiServices= Services();
    print("?????????????????????????????????");
    print(apiServices);
    await apiServices.getDocumenttype();


//_currentSelectedValue=data;
    if (mounted) {
      setState(() {});
    }
  }



  @override
  void initState() {
    super.initState();
    _currSelectedDoc = widget.selectedDocumentType;
  }

  List<Widget> get appBarActions {
    return ([
      Center(child: Text("Tabs:")),
      Switch(
        activeColor: Colors.white,
        value: asTabs,
        onChanged: (value) {
          setState(() {
            asTabs = value;
          });
        },
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: CustomizedColors.accentColor,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.95,
      child: SearchableDropdown.single(
        closeButton: Text(
          "",
          style: TextStyle(fontSize: 0.1),
        ),
        displayClearIcon: false,
        //validator: (value) => value == null ? 'Cannot be empty' : null,
        hint: Text('Document Type'),

        items: data.map((item) {
          return DropdownMenuItem<ExternalDocumentTypesList>(
              child: Text(
                item.externalDocumentTypeName,
                overflow: TextOverflow.ellipsis,
              ),
              value: item);
        }).toList(),
        isExpanded: true,
        underline: Padding(
          padding: EdgeInsets.all(1),
        ),
        value: externalDocumentTypesList,
        searchHint: Text('Select ', style: TextStyle(fontSize: 20)),
        onChanged: (value) {
          setState(() {
            externalDocumentTypesList = value;
            widget.onTapDocument(value);
          });
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
