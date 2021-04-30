// import 'dart:async';
// import 'dart:collection';
// import 'dart:ui';
//
// import 'package:YOURDRS_FlutterAPP/blocs/home/patient_bloc.dart';
// import 'package:YOURDRS_FlutterAPP/blocs/home/patient_bloc_event.dart';
// import 'package:YOURDRS_FlutterAPP/blocs/home/patient_bloc_state.dart';
// import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
// import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
// import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
// import 'package:YOURDRS_FlutterAPP/common/app_loader.dart';
// import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
// import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
// import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
// import 'package:YOURDRS_FlutterAPP/network/models/home/dictation.dart';
// import 'package:YOURDRS_FlutterAPP/network/models/home/provider.dart';
// import 'package:YOURDRS_FlutterAPP/network/models/home/schedule.dart';
// import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
// import 'package:YOURDRS_FlutterAPP/ui/home/drawer.dart';
// import 'package:YOURDRS_FlutterAPP/ui/home/filter_screen.dart';
// import 'package:YOURDRS_FlutterAPP/ui/home/grouping_seperator.dart';
// import 'package:YOURDRS_FlutterAPP/ui/home/patient_details.dart';
// import 'package:YOURDRS_FlutterAPP/widget/date_range_picker.dart';
// import 'package:YOURDRS_FlutterAPP/widget/dropdowns/dictation.dart';
// import 'package:YOURDRS_FlutterAPP/widget/dropdowns/location.dart';
// import 'package:YOURDRS_FlutterAPP/widget/dropdowns/provider.dart';
// import 'package:YOURDRS_FlutterAPP/widget/input_fields/search_bar.dart';
// import 'package:animations/animations.dart';
// import 'package:date_picker_timeline/date_picker_widget.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:grouped_list/grouped_list.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// // final GlobalKey _key = GlobalKey();
//
// class DeBouncer {
//   final int milliseconds;
//   VoidCallback action;
//   Timer _timer;
//
//   DeBouncer({this.milliseconds});
//
//   run(VoidCallback action) {
//     try {
//       if (null != _timer) {
//         _timer.cancel();
//       }
//     } catch (e) {
//       throw Exception();
//     }
//     _timer = Timer(Duration(milliseconds: milliseconds), action);
//   }
// }
//
// class PatientAppointment extends StatefulWidget {
//   static const String routeName = '/HomeScreen';
//
//   @override
//   _PatientAppointmentState createState() => _PatientAppointmentState();
// }
//
// class _PatientAppointmentState extends State<PatientAppointment> {
//   final _deBouncer = DeBouncer(milliseconds: 500);
//   var displayName = "";
//   var profilePic = "";
//   var selectedDate;
//   String codeDialog;
//   String valueText;
//   bool init = false;
//   bool isShowToast = false;
//
//   // Declared Variables for start Date and end Date
//   String startDate;
//   String endDate;
//
//   //var for selected Provider Id ,Dictation Id,Location Id
//   var _currentSelectedProviderId;
//   var _currentSelectedLocationId;
//   var _currentSelectedDictationId;
//
//   // list of Patients
//   // ignore: deprecated_member_use
//   List<ScheduleList> patients = List();
//
//   // ignore: deprecated_member_use
//   List<ScheduleList> filteredPatients = List();
//
//   //boolean property for visibility for search and clear filter
//   bool visibleSearchFilter = false;
//   bool visibleClearFilter = true;
//
//   //boolean property for visibility for Date Picker
//   bool datePicker = true;
//   bool dateRange = false;
//
//   //Infinite Scroll Pagination related code//
//   var _scrollController = ScrollController();
//   double maxScroll, currentScroll;
//   int page;
//
//   //counting for each practice location using hashMap
//   HashMap<String, int> practiceCountMap = HashMap();
//   HashMap<String, String> locationName = HashMap();
//   bool isLoadingVertical = false;
//   Map<String, dynamic> appointment;
//
//   /// Creating an object of class
//   AppToast appToast = AppToast();
//   CancelToken cancelToken = CancelToken();
//
//   /// TextField Controller
//   TextEditingController _textFieldController = TextEditingController();
//   DatePickerController _controller = DatePickerController();
//   DateTime _selectedValue = DateTime.now();
//
//   /// initState
//   @override
//   void initState() {
//     super.initState();
//     page = 1;
//     BlocProvider.of<PatientBloc>(context).add(GetSchedulePatientsList(
//         keyword1: null,
//         providerId: null,
//         locationId: null,
//         dictationId: null,
//         startDate: null,
//         endDate: null,
//         pageKey: page));
//     _loadData();
//     Future.delayed(Duration(milliseconds: 500), () {
//       _controller?.animateToDate(DateTime.now().subtract(Duration(days: 3)));
//     });
//   }
//
//   /// Adding the list of value when scrolled
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _scrollController.addListener(_onScroll);
//   }
//
//   void _onScroll() {
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     try {
//       if (maxScroll > 0 && currentScroll > 0 && maxScroll == currentScroll) {
//         page = page + 1;
//         BlocProvider.of<PatientBloc>(context).add(GetSchedulePatientsList(
//             keyword1: selectedDate,
//             providerId: _currentSelectedProviderId,
//             locationId: _currentSelectedLocationId,
//             dictationId: _currentSelectedDictationId,
//             startDate: startDate,
//             endDate: endDate,
//             pageKey: page));
//       }
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }
//
//   /// dispose method
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     cancelToken.cancel("cancelled");
//     super.dispose();
//   }
//
//   /// get the sharedPreference values
//   _loadData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       displayName = (prefs.getString(Keys.displayName) ?? '');
//       profilePic = (prefs.getString(Keys.displayPic) ?? '');
//     });
//   }
//
//   /// Build Method
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _appBarWidget(),
//       drawer: DrawerScreen(),
//       body: _getBody(),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: CustomizedColors.primaryColor,
//         child: Icon(Icons.add),
//         onPressed: () {},
//       ),
//     );
//   }
//
//   /// AppBar
//   Widget _appBarWidget() {
//     final width = MediaQuery.of(context).size.width;
//     return AppBar(
//       backgroundColor: CustomizedColors.primaryColor,
//       actions: [
//         Padding(
//           padding: const EdgeInsets.all(10),
//           child: CircleAvatar(backgroundImage: NetworkImage(profilePic)),
//         ),
//         SizedBox(width: 10),
//         Center(
//           child: Container(
//             width: width * 0.5,
//             child: Text(
//               AppStrings.welcome + ' ' + displayName ?? "",
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//               softWrap: true,
//               style: TextStyle(
//                   color: CustomizedColors.textColor,
//                   fontSize: 14.0,
//                   fontFamily: AppFonts.regular,
//                   fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//         SizedBox(width: 5),
//         OpenContainer(
//           closedColor: CustomizedColors.primaryColor,
//           openColor: CustomizedColors.whiteColor,
//           openShape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(20.0)),
//           ),
//           closedShape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(50.0)),
//           ),
//           transitionType: ContainerTransitionType.fadeThrough,
//           transitionDuration: const Duration(milliseconds: 1000),
//           openBuilder: (context, action) {
//             return FilterScreen();
//           },
//           closedBuilder: (context, action) {
//             return Image.asset(AppImages.filterImage);
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _getBody() {
//     final width = MediaQuery.of(context).size.width;
//     return Column(
//       children: <Widget>[
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             SizedBox(
//               height: 40.0,
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: 15.0, right: 15.0),
//               child: PatientSerach(
//                 width: 250,
//                 height: 60,
//                 controller: _textFieldController,
//                 onChangedValue: (string) {
//                   _deBouncer.run(() {
//                     BlocProvider.of<PatientBloc>(context)
//                         .add(SearchPatientEvent(keyword: string));
//                   });
//                 },
//               ),
//             ),
//             SizedBox(height: 15.0),
//           ],
//         ),
//         SizedBox(
//           height: 15.0,
//         ),
//         Stack(
//           children: <Widget>[
//             SizedBox(
//               height: 10.0,
//             ),
//             Material(
//               elevation: 1.0,
//               child: Container(
//                 height: 75.0,
//                 color: Colors.white,
//               ),
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Visibility(
//                   visible: datePicker,
//                   child: Container(
//                     color: Colors.grey[100],
//                     child: DatePicker(
//                       DateTime.now().subtract(Duration(days: 365)),
//                       width: width < 600 ? 50.0 : 120.0,
//                       height: 80,
//                       controller: _controller,
//                       initialSelectedDate: DateTime.now(),
//                       selectionColor: CustomizedColors.primaryColor,
//                       selectedTextColor: CustomizedColors.textColor,
//                       dayTextStyle: TextStyle(
//                           fontSize: 12.0, fontFamily: AppFonts.regular),
//                       dateTextStyle: TextStyle(
//                           fontSize: 12.0, fontFamily: AppFonts.regular),
//                       monthTextStyle: TextStyle(
//                           fontSize: 12.0, fontFamily: AppFonts.regular),
//                       onDateChange: (date) {
//                         // New date selected
//                         setState(() {
//                           _selectedValue = date;
//                           selectedDate = AppConstants.parseDate(
//                               -1, AppConstants.MMDDYYYY,
//                               dateTime: _selectedValue);
//                           page = 1;
//                           // getSelectedDateAppointments();
//                           BlocProvider.of<PatientBloc>(context).add(
//                               GetSchedulePatientsList(
//                                   keyword1: selectedDate,
//                                   providerId: null,
//                                   locationId: null,
//                                   dictationId: null,
//                                   pageKey: page));
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//                 Visibility(
//                     visible: dateRange,
//                     child: Center(
//                         child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text("Selected date range is",
//                                   style: TextStyle(
//                                       color: CustomizedColors.buttonTitleColor,
//                                       fontSize: 16.0,
//                                       fontFamily: AppFonts.regular,
//                                       fontWeight: FontWeight.bold)),
//                               Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Padding(
//                                         padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
//                                     Text(
//                                       '${AppConstants.parseDatePattern(startDate, AppConstants.MMMddyyyy)}' ??
//                                           "",
//                                       style: TextStyle(
//                                           fontFamily: AppFonts.regular,
//                                           color: CustomizedColors.buttonTitleColor,
//                                           fontSize: 16.0,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     Text(
//                                       '-',
//                                       style: TextStyle(
//                                           fontFamily: AppFonts.regular,
//                                           color: CustomizedColors.buttonTitleColor,
//                                           fontSize: 16.0,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     Text(
//                                         '${AppConstants.parseDatePattern(endDate, AppConstants.MMMddyyyy)}' ??
//                                             "",
//                                         style: TextStyle(
//                                             fontFamily: AppFonts.regular,
//                                             color:
//                                             CustomizedColors.buttonTitleColor,
//                                             fontSize: 16.0,
//                                             fontWeight: FontWeight.bold))
//                                   ]),
//                             ])))
//               ],
//             )
//           ],
//         ),
//         patientAppointmentCard()
//       ],
//     );
//   }
//
//   // patient Appointment card related code//
//   Widget patientAppointmentCard() {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//     return Container(
//       height: width > 600
//           ? MediaQuery.of(context).size.height * 0.73
//           : height * 0.50,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(30), topRight: Radius.circular(30)),
//         color: CustomizedColors.textColor,
//       ),
//       child: SingleChildScrollView(
//         physics: AlwaysScrollableScrollPhysics(),
//         controller: _scrollController,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             BlocBuilder<PatientBloc, PatientAppointmentBlocState>(
//                 builder: (context, state) {
//                   try {
//                     if (state.isLoading &&
//                         (state.patients == null || state.patients.isEmpty)) {
//                       // showLoadingDialog(context, text: 'Getting appointments');
//                       return CustomizedCircularProgressBar();
//                     }
//                   } catch (e) {
//                     throw Exception("Error");
//                   }
//                   try {
//                     if (state.errorMsg != null && state.errorMsg.isNotEmpty) {
//                       return Container(
//                         padding: EdgeInsets.only(top: 175),
//                         child: Center(
//                             child: Text(
//                               state.errorMsg,
//                               style: TextStyle(
//                                   fontFamily: AppFonts.regular,
//                                   color: CustomizedColors.buttonTitleColor,
//                                   fontSize: 20.0,
//                                   fontWeight: FontWeight.bold),
//                             )),
//                       );
//                     }
//                   } catch (e) {
//                     throw Exception(e.toString());
//                   }
//                   try {
//                     if (state.patients == null || state.patients.isEmpty) {
//                       return Text(
//                         AppStrings.nopatients,
//                         style: TextStyle(
//                             fontFamily: AppFonts.regular,
//                             fontSize: 18.0,
//                             fontWeight: FontWeight.bold,
//                             color: CustomizedColors.noAppointment),
//                       );
//                     }
//                   } catch (e) {
//                     throw Exception(e.toString());
//                   }
//                   patients = state.patients;
//                   try {
//                     if (state.keyword != null && state.keyword.isNotEmpty) {
//                       filteredPatients = patients
//                           .where((u) => (u.patient.displayName
//                           .toLowerCase()
//                           .contains(state.keyword.toLowerCase())))
//                           .toList();
//                     } else {
//                       filteredPatients = patients;
//                     }
//                   } catch (e) {
//                     throw Exception(e.toString());
//                   }
//
//                   try {
//                     if (page > 1 && state.hasReachedMax == true) {
//                       String value1 = AppStrings.noData;
//
//                       if (!isShowToast) {
//                         isShowToast = true;
//                         Fluttertoast.showToast(msg: value1).then((value1) {
//                           Fluttertoast.cancel();
//                         });
//                       }
//                     }
//                   } catch (e) {
//                     throw Exception(e.toString());
//                   }
//
//                   /// display count of practice for loop
//                   practiceCountMap.clear();
//                   filteredPatients.forEach((element) {
//                     int practiceCount = practiceCountMap[element.practice];
//                     if (practiceCount == null) {
//                       practiceCount = 0;
//                     }
//
//                     ///count [patients]
//                     practiceCountMap[element.practice] = practiceCount + 1;
//                     locationName[element.practice] = element.location.locationName;
//                   });
//                   return filteredPatients != null && filteredPatients.isNotEmpty
//                       ? Card(
//                     child: GroupedListView<dynamic, String>(
//                       physics: NeverScrollableScrollPhysics(),
//                       elements: filteredPatients,
//                       shrinkWrap: true,
//                       groupBy: (filteredPatients) {
//                         return '${filteredPatients.practice}';
//                       },
//                       groupSeparatorBuilder: (String practice) =>
//                           TransactionGroupSeparator(
//                               practice: practice,
//                               appointmentsCount: practiceCountMap[practice],
//                               locationName: locationName[practice]),
//                       order: GroupedListOrder.ASC,
//                       separator: Container(
//                           height: 1.0, color: CustomizedColors.divider),
//                       itemBuilder: (context, element) => InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => PatientDetail(),
//                               settings: RouteSettings(
//                                 arguments: element,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Material(
//                           child: Container(
//                             height: 90,
//                             padding: EdgeInsets.only(
//                                 left: 10, right: 15, top: 5, bottom: 5),
//                             color: CustomizedColors.iconColor,
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Center(
//                                   child: Hero(
//                                     transitionOnUserGestures: true,
//                                     tag: element,
//                                     child: Transform.scale(
//                                       scale: 1.0,
//                                       child: element.isNewPatient == true
//                                           ? Icon(
//                                         Icons.bookmark,
//                                         color: CustomizedColors
//                                             .bookMarkIconColour,
//                                       )
//                                           : Icon(
//                                         Icons.bookmark,
//                                         color:
//                                         CustomizedColors.background,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 20),
//                                 Expanded(
//                                   child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.center,
//                                       children: [
//                                         Text(element.patient.displayName,
//                                             style: TextStyle(
//                                                 fontFamily: AppFonts.regular,
//                                                 fontSize: 14.0,
//                                                 fontWeight: FontWeight.w600)),
//                                         Text(
//                                             "Dr." +
//                                                 "" +
//                                                 element.providerName ??
//                                                 "",
//                                             overflow: TextOverflow.ellipsis,
//                                             style: TextStyle(
//                                               fontSize: 12.0,
//                                               fontFamily: AppFonts.regular,
//                                             )),
//                                         Text(
//                                           element.scheduleName ?? "",
//                                           style: TextStyle(
//                                             fontSize: 12.0,
//                                             fontFamily: AppFonts.regular,
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         Text(
//                                           element.appointmentStatus ?? "",
//                                           overflow: TextOverflow.ellipsis,
//                                           style: TextStyle(
//                                             fontSize: 12.0,
//                                             fontFamily: AppFonts.regular,
//                                           ),
//                                         ),
//                                       ]),
//                                 ),
//                                 element.dictationStatus == "Pending"
//                                     ? Column(
//                                   crossAxisAlignment:
//                                   CrossAxisAlignment.end,
//                                   mainAxisSize: MainAxisSize.max,
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     AppConstants.parseDate(-1,
//                                         AppConstants.yyyyMMdd,
//                                         dateTime: DateTime
//                                             .parse(element
//                                             .appointmentStartDate)) ==
//                                         AppConstants.parseDate(-1,
//                                             AppConstants.yyyyMMdd,
//                                             dateTime:
//                                             DateTime.now())
//                                         ? Text(
//                                       AppConstants.parseDate(
//                                           -1, AppConstants.hhmma,
//                                           dateTime: DateTime
//                                               .parse(element
//                                               .appointmentStartDate)),
//                                       style: TextStyle(
//                                         fontFamily:
//                                         AppFonts.regular,
//                                       ),
//                                     )
//                                         : Text(
//                                       AppConstants.parseDate(-1,
//                                           AppConstants.MMMddyyyy,
//                                           dateTime: DateTime
//                                               .parse(element
//                                               .appointmentStartDate)),
//                                       style: TextStyle(
//                                         fontFamily:
//                                         AppFonts.regular,
//                                       ),
//                                     ),
//                                     SizedBox(height: 22),
//                                     RichText(
//                                       text: TextSpan(
//                                         text: '• ',
//                                         style: TextStyle(
//                                             color: CustomizedColors
//                                                 .dictationPending,
//                                             fontSize: 14,
//                                             fontFamily:
//                                             AppFonts.regular,
//                                             fontWeight:
//                                             FontWeight.bold),
//                                         children: <TextSpan>[
//                                           TextSpan(
//                                               text: 'Dictation' +
//                                                   " " +
//                                                   element
//                                                       .dictationStatus ??
//                                                   "",
//                                               style: TextStyle(
//                                                   fontFamily:
//                                                   AppFonts.regular,
//                                                   color: CustomizedColors
//                                                       .dictationStatusColor,
//                                                   fontSize: 12)),
//                                         ],
//                                       ),
//                                     )
//                                   ],
//                                 )
//                                     : element.dictationStatus ==
//                                     "Dictation Completed"
//                                     ? Column(
//                                   crossAxisAlignment:
//                                   CrossAxisAlignment.end,
//                                   mainAxisSize: MainAxisSize.max,
//                                   mainAxisAlignment:
//                                   MainAxisAlignment
//                                       .spaceBetween,
//                                   children: [
//                                     AppConstants.parseDate(
//                                         -1,
//                                         AppConstants
//                                             .yyyyMMdd,
//                                         dateTime: DateTime
//                                             .parse(element
//                                             .appointmentStartDate)) ==
//                                         AppConstants.parseDate(
//                                             -1,
//                                             AppConstants
//                                                 .yyyyMMdd,
//                                             dateTime:
//                                             DateTime.now())
//                                         ? Text(
//                                       AppConstants.parseDate(
//                                           -1,
//                                           AppConstants.hhmma,
//                                           dateTime: DateTime
//                                               .parse(element
//                                               .appointmentStartDate)),
//                                       style: TextStyle(
//                                         fontFamily:
//                                         AppFonts.regular,
//                                       ),
//                                     )
//                                         : Text(
//                                       AppConstants.parseDate(
//                                           -1,
//                                           AppConstants
//                                               .MMMddyyyy,
//                                           dateTime: DateTime
//                                               .parse(element
//                                               .appointmentStartDate)),
//                                       style: TextStyle(
//                                         fontFamily:
//                                         AppFonts.regular,
//                                       ),
//                                     ),
//                                     // SizedBox(height: 20),
//                                     RichText(
//                                       text: TextSpan(
//                                         text: '• ',
//                                         style: TextStyle(
//                                             color: CustomizedColors
//                                                 .dictationCompleted,
//                                             fontSize: 14,
//                                             fontFamily:
//                                             AppFonts.regular,
//                                             fontWeight:
//                                             FontWeight.bold),
//                                         children: <TextSpan>[
//                                           TextSpan(
//                                               text: element
//                                                   .dictationStatus ??
//                                                   "",
//                                               style: TextStyle(
//                                                   color: CustomizedColors
//                                                       .dictationStatusColor,
//                                                   fontSize: 12,
//                                                   fontFamily:
//                                                   AppFonts
//                                                       .regular,
//                                                   fontWeight:
//                                                   FontWeight
//                                                       .w500)),
//                                         ],
//                                       ),
//                                     )
//                                   ],
//                                 )
//                                     : element.dictationStatus ==
//                                     "Not Applicable"
//                                     ? AppConstants.parseDate(-1,
//                                     AppConstants.yyyyMMdd,
//                                     dateTime: DateTime
//                                         .parse(element
//                                         .appointmentStartDate)) ==
//                                     AppConstants.parseDate(-1,
//                                         AppConstants.yyyyMMdd,
//                                         dateTime:
//                                         DateTime.now())
//                                     ? Text(
//                                   AppConstants.parseDate(-1,
//                                       AppConstants.hhmma,
//                                       dateTime: DateTime
//                                           .parse(element
//                                           .appointmentStartDate)),
//                                   style: TextStyle(
//                                     fontFamily:
//                                     AppFonts.regular,
//                                   ),
//                                 )
//                                     : Text(
//                                   AppConstants.parseDate(
//                                       -1,
//                                       AppConstants
//                                           .MMMddyyyy,
//                                       dateTime: DateTime
//                                           .parse(element
//                                           .appointmentStartDate)),
//                                   style: TextStyle(
//                                     fontFamily:
//                                     AppFonts.regular,
//                                   ),
//                                 )
//                                     : Container(),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                       : Container(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Padding(padding: EdgeInsets.only(top: 175)),
//                         Center(
//                           child: Text(
//                             AppStrings.noresultsfoundrelatedsearch,
//                             style: TextStyle(
//                                 fontFamily: AppFonts.regular,
//                                 fontSize: 20.0,
//                                 fontWeight: FontWeight.bold,
//                                 color: CustomizedColors.buttonTitleColor),
//                           ),
//                         )
//                       ],
//                     ),
//                   );
//                 }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   _filterDialog(BuildContext buildContext) {
//     FocusScope.of(context).requestFocus(new FocusNode());
//     _textFieldController.clear();
//     return showDialog(
//       context: buildContext,
//       builder: (ctx) => ListView(
//         children: [
//           Padding(
//             padding: EdgeInsets.only(top: 75),
//             child: AlertDialog(
//               title: Text(
//                 AppStrings.selectfilter,
//                 style: GoogleFonts.montserrat(),
//               ),
//               actions: <Widget>[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 250,
//                       child: ProviderDropDowns(onTapOfProviders: (newValue) {
//                         setState(
//                               () {
//                             _currentSelectedProviderId =
//                                 (newValue as ProviderList).providerId;
//                           },
//                         );
//                       }),
//                     )
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 250,
//                       child: Dictation(onTapOfDictation: (newValue) {
//                         setState(() {
//                           _currentSelectedDictationId =
//                               (newValue as DictationStatus).dictationstatusid;
//                         });
//                       }),
//                     )
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 250,
//                       child: LocationDropDown(onTapOfLocation: (newValue) {
//                         _currentSelectedLocationId = newValue.locationId;
//                       }),
//                     )
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: 55,
//                       width: 245,
//                       margin: EdgeInsets.only(top: 5),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(5.0),
//                           border: Border.all(
//                               color: CustomizedColors.homeSubtitleColor)),
//                       child: RaisedButton.icon(
//                           padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
//                           onPressed: () async {
//                             final List<String> result = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => DateFilter()));
//                             startDate = result.first;
//                             endDate = result.last;
//                           },
//                           shape: RoundedRectangleBorder(
//                               borderRadius:
//                               BorderRadius.all(Radius.circular(5.0))),
//                           label: Text(
//                             AppStrings.datafiltertitle,
//                             style: GoogleFonts.montserrat(
//                                 fontSize: 16.0,
//                                 color: CustomizedColors.buttonTitleColor),
//                           ),
//                           icon: Icon(Icons.date_range),
//                           splashColor: CustomizedColors.primaryColor,
//                           color: Colors.white),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: 55,
//                       width: 245,
//                       margin: EdgeInsets.only(top: 5),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(5.0),
//                           border: Border.all(
//                               color: CustomizedColors.homeSubtitleColor)),
//                       child: RaisedButton.icon(
//                           padding: EdgeInsets.only(left: 25),
//                           onPressed: () {
//                             return showDialog(
//                                 context: context,
//                                 builder: (ctx) {
//                                   return AlertDialog(
//                                     title: Text(AppStrings.searchpatienttitle),
//                                     content: TextField(
//                                       onChanged: (value) {
//                                         setState(() {
//                                           valueText = value;
//                                         });
//                                       },
//                                       controller: this._textFieldController,
//                                       decoration: InputDecoration(
//                                           hintText:
//                                           AppStrings.searchpatienttitle),
//                                     ),
//                                     actions: <Widget>[
//                                       FlatButton(
//                                         color: CustomizedColors.accentColor,
//                                         textColor: Colors.white,
//                                         child: Text(AppStrings.cancel),
//                                         onPressed: () {
//                                           setState(() {
//                                             Navigator.pop(ctx);
//                                           });
//                                         },
//                                       ),
//                                       FlatButton(
//                                         color: CustomizedColors.accentColor,
//                                         textColor: Colors.white,
//                                         child: Text(AppStrings.ok),
//                                         onPressed: () {
//                                           setState(() {
//                                             codeDialog = valueText;
//                                             Navigator.pop(ctx);
//                                           });
//                                         },
//                                       ),
//                                     ],
//                                   );
//                                 });
//                           },
//                           shape: RoundedRectangleBorder(
//                               borderRadius:
//                               BorderRadius.all(Radius.circular(5.0))),
//                           label: Text(
//                             AppStrings.searchpatient ??
//                                 "${this._textFieldController.text}",
//                             style: GoogleFonts.montserrat(
//                               fontSize: 16.0,
//                               color: CustomizedColors.buttonTitleColor,
//                             ),
//                           ),
//                           icon: Icon(Icons.search),
//                           splashColor: CustomizedColors.primaryColor,
//                           color: Colors.white),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: 55,
//                       width: 245,
//                       margin: EdgeInsets.only(top: 5),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(5.0),
//                           border: Border.all(
//                               color: CustomizedColors.homeSubtitleColor)),
//                       child: RaisedButton.icon(
//                           padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
//                           onPressed: () {
//                             FocusScope.of(context)
//                                 .requestFocus(new FocusNode());
//                             _textFieldController.clear();
//                             setState(() {
//                               visibleSearchFilter = false;
//                               visibleClearFilter = true;
//                               datePicker = true;
//                               dateRange = false;
//                             });
//                             Future.delayed(Duration(milliseconds: 500), () {
//                               _controller?.animateToDate(
//                                   DateTime.now().subtract(Duration(days: 3)));
//                             });
//                             Navigator.pop(context);
//                             page = 1;
//                             BlocProvider.of<PatientBloc>(context).add(
//                                 GetSchedulePatientsList(
//                                     keyword1: null,
//                                     providerId: null,
//                                     locationId: null,
//                                     dictationId: null,
//                                     startDate: null,
//                                     endDate: null,
//                                     searchString: null,
//                                     pageKey: page));
//                           },
//                           shape: RoundedRectangleBorder(
//                               borderRadius:
//                               BorderRadius.all(Radius.circular(5.0))),
//                           label: Text(
//                             AppStrings.clearfiltertxt,
//                             style: GoogleFonts.montserrat(
//                                 fontSize: 16.0,
//                                 color: CustomizedColors.buttonTitleColor),
//                           ),
//                           icon: Icon(Icons.filter_alt_sharp),
//                           splashColor: CustomizedColors.primaryColor,
//                           color: Colors.white),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     FlatButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Text(AppStrings.cancel,
//                           style: TextStyle(
//                               color: CustomizedColors.primaryColor,
//                               fontSize: 12.0)),
//                     ),
//                     FlatButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         setState(() {
//                           visibleSearchFilter = true;
//                           visibleClearFilter = false;
//                           try {
//                             if (startDate != null && endDate != null) {
//                               dateRange = true;
//                               datePicker = false;
//                             } else {
//                               dateRange = false;
//                               datePicker = true;
//                             }
//                           } catch (e) {
//                             throw Exception(e.toString());
//                           }
//                         });
//                         page = 1;
//                         BlocProvider.of<PatientBloc>(context).add(
//                             GetSchedulePatientsList(
//                                 keyword1: null,
//                                 providerId: _currentSelectedProviderId != null
//                                     ? _currentSelectedProviderId
//                                     : null,
//                                 locationId: _currentSelectedLocationId != null
//                                     ? _currentSelectedLocationId
//                                     : null,
//                                 dictationId: _currentSelectedDictationId != null
//                                     ? int.tryParse(_currentSelectedDictationId)
//                                     : null,
//                                 startDate: startDate != "" ? startDate : null,
//                                 endDate: endDate != "" ? endDate : null,
//                                 searchString:
//                                 this._textFieldController.text != null
//                                     ? this._textFieldController.text
//                                     : null,
//                                 pageKey: page));
//                       },
//                       child: Text(AppStrings.ok,
//                           style: TextStyle(
//                               color: CustomizedColors.primaryColor,
//                               fontSize: 12.0)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
