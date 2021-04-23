import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/location_field_model.dart';
import 'package:YOURDRS_FlutterAPP/network/services/schedules/appointment_service.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/searchable_dropdown.dart';
import 'package:flutter/material.dart';
class Locations extends StatefulWidget {
  final String PracticeIdList;
  final onTapOfLocation;
  const Locations(
      {@required this.onTapOfLocation, @required this.PracticeIdList});
  @override
  _LocationsState createState() => _LocationsState();
}

class _LocationsState extends State<Locations>
    with AutomaticKeepAliveClientMixin {
  bool asTabs = false;
  Services apiServices = Services();
  LocationList locationsList;
  var _currentSelectedValue;

  List data = List();
  String practiceId;
  void initState() {
    super.initState();
    _currentSelectedValue = widget.PracticeIdList;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
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
    if (practiceId == null ||
        (widget.PracticeIdList != null &&
            practiceId != widget.PracticeIdList)) {
      practiceId = widget.PracticeIdList;
      apiServices.getExternalLocation(practiceId).then((value) {
        data = value.locationList;
        if (mounted) {
          setState(() {});
        }
      });
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      child: SearchableDropdown.single(
        closeButton: Text(
          "",
          style: TextStyle(fontSize: 0.1),
        ),
        underline: Padding(padding: EdgeInsets.all(1)),
        displayClearIcon: false,
        hint: Text(AppStrings.selectpractice_text),
        items: data.map((item) {
          return DropdownMenuItem<LocationList>(
              child: Text(
                item.name ?? "",
                overflow: TextOverflow.ellipsis,
              ),
              value: item);
        }).toList(),
        isExpanded: true,
        value: locationsList,
        searchHint: Text('Select ', style: TextStyle(fontSize: 20)),
        onChanged: (value) {
          setState(() {
            _currentSelectedValue = value;
            widget.onTapOfLocation(value);
          });
        },
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: CustomizedColors.accentColor,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
