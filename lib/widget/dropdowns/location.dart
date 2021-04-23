import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
// import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/searchable_dropdown.dart';
import '../../network/services/schedules/appointment_service.dart';
import 'package:flutter/material.dart';

import '../../network/models/home/location.dart';

class LocationDropDown extends StatefulWidget {
  final onTapOfLocation;
  final String selectedLocationId;
  LocationDropDown({@required this.onTapOfLocation, this.selectedLocationId});
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<LocationDropDown> {
  Services apiServices = Services();
  LocationList locationList;
  List<LocationList> _list = [];

// --------> get and decode the API data <-----------
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    Locations location = await apiServices.getLocation();
    _list = location.locationList;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),

      width: MediaQuery.of(context).size.width*0.70,

// ----------> displaying Location list from API in SearchableDropdown <--------
      child: SearchableDropdown.single(
        displayClearIcon: false,
        hint: Text(AppStrings.lochinttxt),
        label: Text(
          AppStrings.loctext,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CustomizedColors.dropdowntxtcolor),
        ),
// ----------> displaying the the data which stored in data of list type <--------
        items: _list.map((item) {
          return DropdownMenuItem<LocationList>(
              child: Text(
                item.locationName,
                overflow: TextOverflow.ellipsis,
              ),
              value: item);
        }).toList(),
        isExpanded: true,
        value: locationList,
        searchHint:
            new Text(AppStrings.lochinttxt, style: new TextStyle(fontSize: 20)),
// ----------> called when a new item is selected <--------
        onChanged: (value) {
          setState(() {
            locationList = value;
          });
          widget.onTapOfLocation(value);
        },
      ),
    );
  }
}
