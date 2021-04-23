import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/network/services/schedules/appointment_service.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:YOURDRS_FlutterAPP/network/models/manual_dictations/appointment_type.dart';

class AppointmentDropDown extends StatefulWidget {
  final onTapOfAppointment;
  String selectedAppointmentType;

  AppointmentDropDown(
      {@required this.onTapOfAppointment, this.selectedAppointmentType});
  @override
  _AppointmentDropDownState createState() => _AppointmentDropDownState();
}

class _AppointmentDropDownState extends State<AppointmentDropDown>
    with AutomaticKeepAliveClientMixin {
  String _currSelectedAppointent;
  bool asTabs = false;
  Services apiServices = Services();
  AppointmentTypeList appointmentTypeList;
  //List<LocationList> _list=[];
  List data = List();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    AppointmentType appointment = await apiServices.getAppointmenttype();
    data = appointment.appointmentTypeList;

//_currentSelectedValue=data;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _currSelectedAppointent = widget.selectedAppointmentType;
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
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.95,
      child: SearchableDropdown.single(
        closeButton: Text(
          "",
          style: TextStyle(fontSize: 0.1),
        ),
        displayClearIcon: false,
        //validator: (value) => value == null ? 'Cannot be empty' : null,
        hint: Text('Appointment Type'),
        // label: Text('',style: TextStyle(
        //     fontSize: 16,fontWeight: FontWeight.bold,
        //     color: Colors.black
        // ),),
        items: data.map((item) {
          return DropdownMenuItem<AppointmentTypeList>(
              child: Text(
                item.name,
                overflow: TextOverflow.ellipsis,
              ),
              value: item);
        }).toList(),
        isExpanded: true,
        underline: Padding(
          padding: EdgeInsets.all(1),
        ),

        value: appointmentTypeList,
        searchHint: Text('Select', style: TextStyle(fontSize: 20)),
        onChanged: (value) {
          setState(() {
            appointmentTypeList = value;
            print('AppointmentTypeList' + "$appointmentTypeList");
            widget.onTapOfAppointment(value);
          });
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
