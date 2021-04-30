// import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
// import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
// import 'package:YOURDRS_FlutterAPP/widget/date_range_picker.dart';
// import 'package:YOURDRS_FlutterAPP/widget/dropdowns/dictation.dart';
// import 'package:YOURDRS_FlutterAPP/widget/dropdowns/location.dart';
// import 'package:YOURDRS_FlutterAPP/widget/dropdowns/provider.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class FilterScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: CustomizedColors.primaryColor,
//         title: Center(
//           child: Text(
//             "Filter appointments",
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//       backgroundColor: CustomizedColors.background,
//       body: ListView(
//         children: [
//           Column(
//             // mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: height * 0.02),
//               Container(
//                 // color: Colors.blue,
//                 width: width,
//                 height: height * 0.1,
//                 child: Column(
//                   children: [
//                     // SizedBox(height: 20),
//                     Container(
//                       // color: Colors.blue,
//                       height: height * 0.08,
//                       width: width * 0.9,
//                       child: Card(
//                         elevation: 10,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: TextFormField(
//                           // controller: _textFieldController,
//                           decoration: InputDecoration(
//                             contentPadding: EdgeInsets.only(left: 20, top: 18),
//                             suffixIcon: Icon(
//                               Icons.search,
//                               color: Colors.grey,
//                             ),
//                             border: InputBorder.none,
//                             hintText: AppStrings.searchpatient,
//                             hintStyle: TextStyle(fontWeight: FontWeight.w400),
//                           ),
//                           onTap: () {
//                             _deBouncer.run(() {
//                               BlocProvider.of<PatientBloc>(context)
//                                   .add(SearchPatientEvent());
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 height: height * 0.13,
//                 width: width * 0.9,
//                 child: Card(
//                   elevation: 10,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20)),
//                   child: ProviderDropDowns(
//                     onTapOfProviders: (newValue) {
//                       setState(() {
//                         _currentSelectedProviderId =
//                             (newValue as ProviderList).providerId;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               Container(
//                 height: height * 0.13,
//                 width: width * 0.9,
//                 child: Card(
//                   elevation: 10,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20)),
//                   child: Dictation(onTapOfDictation: (newValue) {
//                     setState(() {
//                       _currentSelectedDictationId =
//                           (newValue as DictationStatus).dictationstatusid;
//                     });
//                   }),
//                 ),
//               ),
//               Container(
//                 height: height * 0.13,
//                 width: width * 0.9,
//                 child: Card(
//                   elevation: 10,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20)),
//                   child: LocationDropDown(onTapOfLocation: (newValue) {
//                     _currentSelectedLocationId = newValue.locationId;
//                   }),
//                 ),
//               ),
//               Container(
//                 // color: Colors.blue,
//                 height: height * 0.13,
//                 width: width * 0.9,
//                 child: InkWell(
//                   onTap: () async {
//                     final List<String> result = await Navigator.push(context,
//                         MaterialPageRoute(builder: (context) => DateFilter()));
//                     startDate = result.first;
//                     endDate = result.last;
//                   },
//                   child: Card(
//                     elevation: 10,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       // mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(width: width * 0.05),
//                         Text(
//                           "Appointment Date",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(width: width * 0.4),
//                         Icon(Icons.calendar_today_rounded)
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: height * 0.08),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       elevation: 10,
//                       child: Center(
//                         child: Padding(
//                           padding: const EdgeInsets.only(
//                               top: 20, bottom: 20, left: 40, right: 40),
//                           child: Text(
//                             "Cancel",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   // SizedBox(width: width * 0.1),
//                   InkWell(
//                     onTap: () {
//                       FocusScope.of(context).requestFocus(new FocusNode());
//                       _textFieldController.clear();
//                       setState(() {
//                         visibleSearchFilter = false;
//                         visibleClearFilter = true;
//                         datePicker = true;
//                         dateRange = false;
//                       });
//                       Future.delayed(Duration(milliseconds: 500), () {
//                         _controller?.animateToDate(
//                             DateTime.now().subtract(Duration(days: 3)));
//                       });
//                       Navigator.pop(context);
//                       page = 1;
//                       BlocProvider.of<PatientBloc>(context).add(
//                           GetSchedulePatientsList(
//                               keyword1: null,
//                               providerId: null,
//                               locationId: null,
//                               dictationId: null,
//                               startDate: null,
//                               endDate: null,
//                               searchString: null,
//                               pageKey: page));
//                     },
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       elevation: 10,
//                       child: Center(
//                         child: Padding(
//                           padding: const EdgeInsets.only(
//                               top: 20, bottom: 20, left: 40, right: 40),
//                           child: Text(
//                             "Clear",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () {
//                       Navigator.of(context).pop();
//                       setState(() {
//                         visibleSearchFilter = true;
//                         visibleClearFilter = false;
//                         try {
//                           if (startDate != null && endDate != null) {
//                             dateRange = true;
//                             datePicker = false;
//                           } else {
//                             dateRange = false;
//                             datePicker = true;
//                           }
//                         } catch (e) {
//                           throw Exception(e.toString());
//                         }
//                       });
//                       page = 1;
//                       BlocProvider.of<PatientBloc>(context).add(
//                           GetSchedulePatientsList(
//                               keyword1: null,
//                               providerId:
//                                   _currentSelectedProviderId !=
//                                           null
//                                       ? _currentSelectedProviderId
//                                       : null,
//                               locationId:
//                                   _currentSelectedLocationId !=
//                                           null
//                                       ? _currentSelectedLocationId
//                                       : null,
//                               dictationId: _currentSelectedDictationId != null
//                                   ? int.tryParse(_currentSelectedDictationId)
//                                   : null,
//                               startDate: startDate != "" ? startDate : null,
//                               endDate: endDate != "" ? endDate : null,
//                               searchString:
//                                   this._textFieldController.text != null
//                                       ? this._textFieldController.text
//                                       : null,
//                               pageKey: page));
//                     },
//                     child: Card(
//                       color: Colors.green,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       elevation: 10,
//                       child: Center(
//                         child: Padding(
//                           padding: const EdgeInsets.only(
//                               top: 20, bottom: 20, left: 40, right: 40),
//                           child: Text(
//                             "Apply",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
