import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:YOURDRS_FlutterAPP/blocs/home/patient_bloc.dart';
import 'package:YOURDRS_FlutterAPP/blocs/home/patient_bloc_event.dart';
import 'package:YOURDRS_FlutterAPP/blocs/home/patient_bloc_state.dart';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
import 'package:YOURDRS_FlutterAPP/common/app_loader.dart';
import 'package:YOURDRS_FlutterAPP/common/app_pop_menu.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_text.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/models/home/dictation.dart';
import 'package:YOURDRS_FlutterAPP/network/models/home/provider.dart';
import 'package:YOURDRS_FlutterAPP/network/models/home/schedule.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/drawer.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/filter_screen.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/patient_details.dart';
import 'package:YOURDRS_FlutterAPP/widget/date_range_picker.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/dictation.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/location.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/provider.dart';
import 'package:animations/animations.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'grouping_seperator.dart';

// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// final GlobalKey _key = GlobalKey();

class DeBouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  DeBouncer({this.milliseconds});

  run(VoidCallback action) {
    try {
      if (null != _timer) {
        _timer.cancel();
      }
    } catch (e) {
      throw Exception();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class PatientAppointment extends StatefulWidget {
  static const String routeName = '/HomeScreen';

  @override
  _PatientAppointmentState createState() => _PatientAppointmentState();
}

class _PatientAppointmentState extends State<PatientAppointment> {
  // final _deBouncer = DeBouncer(milliseconds: 500);
  var displayName = "";
  var profilePic = "";
  var selectedDate;
  String codeDialog;
  String valueText;
  bool init = false;
  bool isShowToast = false;

  // Declared Variables for start Date and end Date
  String startDate;
  String endDate;

  //var for selected Provider Id ,Dictation Id,Location Id
  var _currentSelectedProviderId;
  var _currentSelectedLocationId;
  var _currentSelectedDictationId;

  // list of Patients
  // ignore: deprecated_member_use
  List<ScheduleList> patients = List();

  // ignore: deprecated_member_use
  List<ScheduleList> filteredPatients = List();

  //boolean property for visibility for search and clear filter
  bool visibleSearchFilter = false;
  bool visibleClearFilter = true;

  //boolean property for visibility for Date Picker
  bool datePicker = true;
  bool dateRange = false;

  //Infinite Scroll Pagination related code//
  var _scrollController = ScrollController();
  double maxScroll, currentScroll;
  int page;

  //counting for each practice location using hashMap
  HashMap<String, int> practiceCountMap = HashMap();
  HashMap<String, String> locationName = HashMap();
  bool isLoadingVertical = false;
  Map<String, dynamic> appointment;

  /// Creating an object of class
  AppToast appToast = AppToast();
  CancelToken cancelToken = CancelToken();

  /// TextField Controller
  TextEditingController _textFieldController = TextEditingController();
  DatePickerController _controller = DatePickerController();
  DateTime _selectedValue = DateTime.now();

  /// initState
  @override
  void initState() {
    super.initState();
    page = 1;
    BlocProvider.of<PatientBloc>(context).add(GetSchedulePatientsList(
        keyword1: null,
        providerId: null,
        locationId: null,
        dictationId: null,
        startDate: null,
        endDate: null,
        pageKey: page));
    _loadData();
    Future.delayed(Duration(milliseconds: 500), () {
      _controller?.animateToDate(DateTime.now().subtract(Duration(days: 3)));
    });
  }

  /// Adding the list of value when scrolled
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    try {
      if (maxScroll > 0 && currentScroll > 0 && maxScroll == currentScroll) {
        page = page + 1;
        BlocProvider.of<PatientBloc>(context).add(GetSchedulePatientsList(
            keyword1: selectedDate,
            providerId: _currentSelectedProviderId,
            locationId: _currentSelectedLocationId,
            dictationId: _currentSelectedDictationId,
            startDate: startDate,
            endDate: endDate,
            pageKey: page));
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// dispose method
  @override
  void dispose() {
    _scrollController.dispose();
    cancelToken.cancel("cancelled");
    super.dispose();
  }

  /// get the sharedPreference values
  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      displayName = (prefs.getString(Keys.displayName) ?? '');
      profilePic = (prefs.getString(Keys.displayPic) ?? '');
    });
  }

  /// Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      drawer: DrawerScreen(),
      body: Container(
        color: CustomizedColors.background,
        child: _getBody(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CustomizedColors.primaryColor,
        child: Pop(
          initialValue: 1,
        ),
        onPressed: () {},
      ),
    );
  }

  /// AppBar
  Widget _appBarWidget() {
    final width = MediaQuery.of(context).size.width;
    return AppBar(
      elevation: 0,
      backgroundColor: CustomizedColors.primaryColor,
      actions: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: CircleAvatar(
            backgroundImage: NetworkImage(profilePic ?? AppImages.doctorImg),
          ),
        ),
        SizedBox(width: 10),
        Center(
          child: Container(
            width: width * 0.5,
            child: Text(
              AppStrings.welcome + ' ' + displayName ?? "",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: true,
              style: TextStyle(
                  color: CustomizedColors.textColor,
                  fontSize: 14.0,
                  fontFamily: AppFonts.regular,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(width: 5),
        OpenContainer(
          closedColor: CustomizedColors.primaryColor,
          openColor: CustomizedColors.whiteColor,
          openShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          closedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
          ),
          transitionType: ContainerTransitionType.fadeThrough,
          transitionDuration: const Duration(milliseconds: 1000),
          openBuilder: (context, action) {
            return _filterWidget();
          },
          closedBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.filter_alt_rounded),
            );
          },
        ),
      ],
    );
  }

  /// body Widget
  Widget _getBody() {
    return ListView(
      children: [
        _searchWidget(),
        SizedBox(height: 40),
        _datePickerWidget(),
        SizedBox(height: 20),
        _patientAppointmentList(),
      ],
    );
  }

  Widget _searchWidget() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.08,
      color: CustomizedColors.primaryColor,
      child: FractionalTranslation(
        translation: Offset(0, 0.5),
        child: Align(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              child: TextFormField(
                controller: _textFieldController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20, top: 18),
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  hintText: AppStrings.searchpatient,
                  hintStyle: TextStyle(fontWeight: FontWeight.w400),
                ),
                // onTap: (){
                //   _deBouncer.run(() {
                //     BlocProvider.of<PatientBloc>(context)
                //         .add(SearchPatientEvent());
                //   });
                // },
              ),
              height: height * 0.5,
              width: width * 0.9,
            ),
          ),
        ),
      ),
    );
  }

  /// DatePicker Widget to select the Particular date to display date
  Widget _datePickerWidget() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: width * 0.99,
        height: height * 0.11,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: datePicker,
              child: DatePicker(
                DateTime.now().subtract(Duration(days: 365)),
                width: width * 0.12,
                height: height * 0.10,
                controller: _controller,
                initialSelectedDate: DateTime.now(),
                selectionColor: CustomizedColors.primaryColor,
                selectedTextColor: CustomizedColors.textColor,
                dateTextStyle:
                    TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                onDateChange: (date) {
                  // New date selected
                  setState(() {
                    page = 1;
                    _selectedValue = date;
                    selectedDate = AppConstants.parseDate(
                        -1, AppConstants.MMDDYYYY,
                        dateTime: _selectedValue);
                    BlocProvider.of<PatientBloc>(context).add(
                      GetSchedulePatientsList(
                          keyword1: selectedDate,
                          providerId: null,
                          locationId: null,
                          dictationId: null,
                          pageKey: page),
                    );
                  });
                },
              ),
            ),
            Visibility(
              visible: dateRange,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dateRange,
                      style: TextStyle(
                          color: CustomizedColors.buttonTitleColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
                        Text(
                          '${AppConstants.parseDatePattern(startDate, AppConstants.MMMddyyyy)}' ??
                              "",
                          style: TextStyle(
                              color: CustomizedColors.buttonTitleColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '-',
                          style: TextStyle(
                              color: CustomizedColors.buttonTitleColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${AppConstants.parseDatePattern(endDate, AppConstants.MMMddyyyy)}' ??
                              "",
                          style: TextStyle(
                              color: CustomizedColors.buttonTitleColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// patientListCard
  Widget _patientAppointmentList() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      decoration: new BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.5),
            blurRadius: 20.0, // soften the shadow
            spreadRadius: 0.0, //extend the shadow
            offset: Offset(
              5.0,
              5.0,
            ),
          )
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        padding: const EdgeInsets.only(top: 30, left: 5, right: 5),
        width: width,
        height: height,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BlocBuilder<PatientBloc, PatientAppointmentBlocState>(
                builder: (context, state) {
                  try {
                    if (state.isLoading &&
                        (state.patients == null || state.patients.isEmpty)) {
                      return CustomizedCircularProgressBar();
                    }
                  } catch (e) {
                    throw Exception("Error");
                  }
                  try {
                    if (state.errorMsg != null && state.errorMsg.isNotEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            Image.asset(AppImages.noAppointment),
                            Text(
                              state.errorMsg,
                              style: TextStyle(
                                  fontFamily: AppFonts.regular,
                                  color: CustomizedColors.email_text_color,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    throw Exception(e.toString());
                  }
                  try {
                    if (state.patients == null || state.patients.isEmpty) {
                      return Column(
                        children: [
                          Image.asset(AppStrings.noresultsfoundrelatedsearch),
                          Text(
                            AppStrings.nopatients,
                            style: TextStyle(
                                fontFamily: AppFonts.regular,
                                color: CustomizedColors.email_text_color,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    }
                  } catch (e) {
                    throw Exception(e.toString());
                  }
                  patients = state.patients;
                  try {
                    if (state.keyword != null && state.keyword.isNotEmpty) {
                      filteredPatients = patients
                          .where((u) => (u.patient.displayName
                              .toLowerCase()
                              .contains(state.keyword.toLowerCase())))
                          .toList();
                    } else {
                      filteredPatients = patients;
                    }
                  } catch (e) {
                    throw Exception(e.toString());
                  }

                  try {
                    if (page > 1 && state.hasReachedMax == true) {
                      String value1 = AppStrings.noData;

                      if (!isShowToast) {
                        isShowToast = true;
                        Fluttertoast.showToast(msg: value1).then((value1) {
                          Fluttertoast.cancel();
                        });
                      }
                    }
                  } catch (e) {
                    throw Exception(e.toString());
                  }

                  /// display count of practice for loop
                  practiceCountMap.clear();
                  filteredPatients.forEach((element) {
                    int practiceCount = practiceCountMap[element.practice];
                    if (practiceCount == null) {
                      practiceCount = 0;
                    }

                    ///count [patients]
                    practiceCountMap[element.practice] = practiceCount + 1;
                    locationName[element.practice] =
                        element.location.locationName;
                  });

                  return filteredPatients != null && filteredPatients.isNotEmpty
                      ? _groupedListView()
                      : _noAppointmentRelatedToSearch();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Grouped ListView Widget to display patients details in groups
  Widget _groupedListView() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return GroupedListView<dynamic, String>(
      physics: NeverScrollableScrollPhysics(),
      elements: filteredPatients,
      shrinkWrap: true,
      groupBy: (filteredPatients) {
        return '${filteredPatients.practice}';
      },
      groupSeparatorBuilder: (String practice) => TransactionGroupSeparator(
          practice: practice,
          appointmentsCount: practiceCountMap[practice],
          locationName: locationName[practice]),
      order: GroupedListOrder.ASC,
      separator: Container(height: 3.0, color: CustomizedColors.background),
      itemBuilder: (context, element) => InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetail(),
              settings: RouteSettings(
                arguments: element,
              ),
            ),
          );
        },
        child: Container(
          // color: Colors.green,
          width: width,
          height: height * 0.14,
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Hero(
                  transitionOnUserGestures: true,
                  tag: element,
                  child: Transform.scale(
                    scale: 1.0,
                    child: element.isNewPatient == true
                        ? Icon(
                            Icons.bookmark,
                            color: CustomizedColors.bookMarkIconColour,
                          )
                        : Icon(
                            Icons.bookmark,
                            color: CustomizedColors.primaryColor,
                          ),
                  ),
                ),
              ),
              SizedBox(width: width * 0.1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      element.patient.displayName,
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: height * 0.015),
                    Text(
                      "Dr." + "" + element.providerName ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(height: height * 0.009),
                    Text(
                      element.scheduleName ?? "",
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: height * 0.009),
                    Text(
                      element.appointmentStatus ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(height: height * 0.009),
                  ],
                ),
              ),
              element.dictationStatus == "Pending"
                  ? _dictationPending(element)
                  : element.dictationStatus == "Dictation Completed"
                      ? _dictationCompleted(element)
                      : element.dictationStatus == "Not Applicable"
                          ? _notApplicable(element)
                          : Container(),
            ],
          ),
        ),
      ),
    );
  }

  /// Dictation Pending
  Widget _dictationPending(element) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppConstants.parseDate(-1, AppConstants.yyyyMMdd,
                    dateTime: DateTime.parse(element.appointmentStartDate)) ==
                AppConstants.parseDate(-1, AppConstants.yyyyMMdd,
                    dateTime: DateTime.now())
            ? Text(
                AppConstants.parseDate(-1, AppConstants.hhmma,
                    dateTime: DateTime.parse(element.appointmentStartDate)),
              )
            : Text(
                AppConstants.parseDate(-1, AppConstants.MMMddyyyy,
                    dateTime: DateTime.parse(element.appointmentStartDate)),
              ),
        SizedBox(height: 22),
        RichText(
          text: TextSpan(
            text: '• ',
            style: TextStyle(
                color: CustomizedColors.dictationPending,
                fontSize: 14,
                fontFamily: AppFonts.regular,
                fontWeight: FontWeight.bold),
            children: <TextSpan>[
              TextSpan(
                  text: 'Dictation' + " " + element.dictationStatus ?? "",
                  style: TextStyle(
                      fontFamily: AppFonts.regular,
                      color: CustomizedColors.dictationStatusColor,
                      fontSize: 12)),
            ],
          ),
        )
      ],
    );
  }

  /// Dictation Completed
  Widget _dictationCompleted(element) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppConstants.parseDate(-1, AppConstants.yyyyMMdd,
                    dateTime: DateTime.parse(element.appointmentStartDate)) ==
                AppConstants.parseDate(-1, AppConstants.yyyyMMdd,
                    dateTime: DateTime.now())
            ? Text(
                AppConstants.parseDate(-1, AppConstants.hhmma,
                    dateTime: DateTime.parse(element.appointmentStartDate)),
                style: TextStyle(
                  fontFamily: AppFonts.regular,
                ),
              )
            : Text(
                AppConstants.parseDate(-1, AppConstants.MMMddyyyy,
                    dateTime: DateTime.parse(element.appointmentStartDate)),
                style: TextStyle(
                  fontFamily: AppFonts.regular,
                ),
              ),
        // SizedBox(height: 20),
        RichText(
          text: TextSpan(
            text: '• ',
            style: TextStyle(
                color: CustomizedColors.dictationCompleted,
                fontSize: 14,
                fontFamily: AppFonts.regular,
                fontWeight: FontWeight.bold),
            children: <TextSpan>[
              TextSpan(
                  text: element.dictationStatus ?? "",
                  style: TextStyle(
                      color: CustomizedColors.dictationStatusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }

  /// Dictation Not Applicable
  Widget _notApplicable(element) {
    return AppConstants.parseDate(-1, AppConstants.yyyyMMdd,
                dateTime: DateTime.parse(element.appointmentStartDate)) ==
            AppConstants.parseDate(-1, AppConstants.yyyyMMdd,
                dateTime: DateTime.now())
        ? Text(
            AppConstants.parseDate(-1, AppConstants.hhmma,
                dateTime: DateTime.parse(element.appointmentStartDate)),
            style: TextStyle(
              fontFamily: AppFonts.regular,
            ),
          )
        : Text(
            AppConstants.parseDate(-1, AppConstants.MMMddyyyy,
                dateTime: DateTime.parse(element.appointmentStartDate)),
            style: TextStyle(
              fontFamily: AppFonts.regular,
            ),
          );
  }

  /// No Appointments on Related Search
  Widget _noAppointmentRelatedToSearch() {
    return Column(
      children: [
        Image.asset(AppStrings.noresultsfoundrelatedsearch),
        Text(
          AppStrings.noresultsfoundrelatedsearch,
          style: TextStyle(
              fontFamily: AppFonts.regular,
              color: CustomizedColors.email_text_color,
              fontSize: 20.0,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }


 Widget _filterWidget(){
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ListView(
      children: [
        Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height * 0.02),
            /// Search Patient Filter
            Container(
              // color: Colors.blue,
              width: width,
              height: height * 0.1,
              child: Column(
                children: [
                  // SizedBox(height: 20),
                  Container(
                    // color: Colors.blue,
                    height: height * 0.08,
                    width: width * 0.9,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        // controller: _textFieldController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 20, top: 18),
                          suffixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          hintText: AppStrings.searchpatient,
                          hintStyle: TextStyle(fontWeight: FontWeight.w400),
                        ),
                        // onTap: () {
                        //   _deBouncer.run(() {
                        //     BlocProvider.of<PatientBloc>(context)
                        //         .add(SearchPatientEvent());
                        //   });
                        // },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            /// Select Provider Filter
            Container(
              height: height * 0.13,
              width: width * 0.9,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: ProviderDropDowns(
                  onTapOfProviders: (newValue) {
                    setState(() {
                      _currentSelectedProviderId =
                          (newValue as ProviderList).providerId;
                    });
                  },
                ),
              ),
            ),
            /// Select Dictation Filter
            Container(
              height: height * 0.13,
              width: width * 0.9,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Dictation(onTapOfDictation: (newValue) {
                  setState(() {
                    _currentSelectedDictationId =
                        (newValue as DictationStatus).dictationstatusid;
                  });
                }),
              ),
            ),
            /// Select Location Filter
            Container(
              height: height * 0.13,
              width: width * 0.9,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: LocationDropDown(onTapOfLocation: (newValue) {
                  _currentSelectedLocationId = newValue.locationId;
                }),
              ),
            ),
            /// Select Appointment Date Filter
            Container(
              // color: Colors.blue,
              height: height * 0.13,
              width: width * 0.9,
              child: InkWell(
                onTap: () async {
                  final List<String> result = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DateFilter()));
                  startDate = result.first;
                  endDate = result.last;
                },
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: width * 0.05),
                      Text(
                        "Appointment Date",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: width * 0.4),
                      Icon(Icons.calendar_today_rounded)
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.08),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Cancel Button in filter Screen
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 20, left: 40, right: 40),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // SizedBox(width: width * 0.1),
                /// Clear Button in filter Screen
                InkWell(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _textFieldController.clear();
                    setState(() {
                      visibleSearchFilter = false;
                      visibleClearFilter = true;
                      datePicker = true;
                      dateRange = false;
                    });
                    Future.delayed(Duration(milliseconds: 500), () {
                      _controller?.animateToDate(
                          DateTime.now().subtract(Duration(days: 3)));
                    });
                    Navigator.pop(context);
                    page = 1;
                    BlocProvider.of<PatientBloc>(context).add(
                        GetSchedulePatientsList(
                            keyword1: null,
                            providerId: null,
                            locationId: null,
                            dictationId: null,
                            startDate: null,
                            endDate: null,
                            searchString: null,
                            pageKey: page));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 20, left: 40, right: 40),
                        child: Text(
                          "Clear",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                /// Apply Button in filter Screen
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      visibleSearchFilter = true;
                      visibleClearFilter = false;
                      try {
                        if (startDate != null && endDate != null) {
                          dateRange = true;
                          datePicker = false;
                        } else {
                          dateRange = false;
                          datePicker = true;
                        }
                      } catch (e) {
                        throw Exception(e.toString());
                      }
                    });
                    page = 1;
                    BlocProvider.of<PatientBloc>(context).add(
                        GetSchedulePatientsList(
                            keyword1: null,
                            providerId:
                            _currentSelectedProviderId !=
                                null
                                ? _currentSelectedProviderId
                                : null,
                            locationId: _currentSelectedLocationId != null
                                ? _currentSelectedLocationId
                                : null,
                            dictationId:
                            _currentSelectedDictationId != null
                                ? int.tryParse(
                                _currentSelectedDictationId)
                                : null,
                            startDate: startDate != "" ? startDate : null,
                            endDate: endDate != "" ? endDate : null,
                            searchString:
                            this._textFieldController.text != null
                                ? this._textFieldController.text
                                : null,
                            pageKey: page));
                    isShowToast = false;
                  },
                  child: Card(
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 20, left: 40, right: 40),
                        child: Text(
                          "Apply",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
