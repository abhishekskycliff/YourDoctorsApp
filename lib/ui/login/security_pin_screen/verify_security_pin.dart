import 'package:YOURDRS_FlutterAPP/blocs/login/pin_validation/pin_screen_validate_bloc.dart';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/network/services/login/pin_validate_api.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/home_screen.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/login_screen/loginscreen.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
final GlobalKey<State> _keyLoader = new GlobalKey<State>();

class VerifyPinScreen extends StatelessWidget {
  static const String routeName = '/VerifyPinScreen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PinScreenBloc>(
      create: (context) => PinScreenBloc(PinRepo()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: PinPutView(),
        ),
      ),
    );
  }
}

class PinPutView extends StatefulWidget {
  @override
  PinPutViewState createState() => PinPutViewState();
}

class PinPutViewState extends State<PinPutView> {
  AppToast appToast=AppToast();
  var name;
  var img;
  bool isInternetAvailable = false;
  final _formKey = GlobalKey<FormState>();
  final pinPutController = TextEditingController();
  var conPin = "";
  var memberId = "";

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      conPin = (prefs.getString(Keys.pinValue) ?? '');
      memberId = (prefs.getString(Keys.memberId) ?? '');
      print(conPin);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  ///for clearing input field.
  clearTextInput() {
    pinPutController.clear();
  }

  ///checking internet connection available or not.
  Future<void> _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        isInternetAvailable = true;
      });
    } else {
      // I am connected to a wifi network.
      setState(() {
        isInternetAvailable = false;
      });

      // appToast.showToast(AppStrings.no_internet);
      // clearTextInput();
    }
  }

  ///Customized dialog for loading...
  Future<void> showLoadingDialog(BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(

            ///onWillPop disables back button for this specific widget.
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: Row(children: [
                        SizedBox(
                          width: 25,
                        ),
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              CustomizedColors.primaryColor),
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
                        )
                      ]),
                    )
                  ]));
        });
  }

  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;
    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return isAvailable;
    // isAvailable;
    return isAvailable;
  }

  /// To retrieve the list of biometric types
  /// (if available).
  Future<void> _getListOfBiometricTypes() async {
    List<BiometricType> listOfBiometrics;
    try {
      listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;
  }
  bool isAuthenticated = false;

  /// Process of authentication user using
  /// biometrics.
  Future<void> _authenticateUser() async {
    try {
      isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason:
        AppStrings.transaction_overview,
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    isAuthenticated;

    if (isAuthenticated) {
      RouteGenerator.navigatorKey.currentState
          .pushNamed(PatientAppointment.routeName);
    }
  }

  String validatePinput(String value) {
    Pattern pattern = r'^[0-9]*$';
    RegExp regex = new RegExp(pattern);
    try {
      if (value.isEmpty) {
        return AppStrings.cannot_be_empty;
      } else {
        if (!regex.hasMatch(value))
          return AppStrings.enterValidPin;
        else {
          return null;
        }
      }
    } catch (Exception) {
      print(Exception);
    }
  }


  void _validateOffLine(){
    var pinPutCon = pinPutController.text;
    // ignore: unrelated_type_equality_checks
    if(conPin == "" || conPin == null){
      appToast.showToast(AppStrings.no_internet);
      print("Turn on the internet");
    }else if(pinPutCon == conPin){
      RouteGenerator.navigatorKey.currentState.pushReplacementNamed(
          PatientAppointment.routeName,
          arguments: memberId);
      print(memberId);
      print("Authentication Successful");
      print(Keys.pinValue);
      print(pinPutController);
    }
    else{
      clearTextInput();
      print("Enter correct Credentials");
      _alertMessage();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(child: _mobileDisplay()),
    );
  }

  Widget _alertMessage() {
    Alert(
      context: context,
      type: AlertType.none,
      title: AppStrings.enterValidPin,
      buttons: [
        DialogButton(
          color: CustomizedColors.primaryColor,
          child: Text(
            AppStrings.ok,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          width: 58,
          height: 40,
        )
      ],
    ).show();
  }

  Widget _mobileDisplay() {
    // TODO: implement build
    final BoxDecoration pinPutDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
    );
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      height: height,
      color: CustomizedColors.PinScreenColor,
      child: BlocListener<PinScreenBloc, PinScreenState>(
        listener: (context, state) {
          setState(() {
            img = state.displayPic;
            name = state.name;
          });
          if (state.isTrue == true) {
            Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
            RouteGenerator.navigatorKey.currentState
                .pushReplacementNamed(PatientAppointment.routeName);
            clearTextInput();
          } else {
            Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
            _alertMessage();
            clearTextInput();
          }
        },
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              AppStrings.yourDrs,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              height: 60,
              child: Image.asset(AppImages.doctorImg),
            )
          ]),
          SizedBox(
            height: height * 0.05,
          ),
          Container(
              height: height * 0.13,
              child: Image.asset(AppImages.pinImage)),
          SizedBox(
            height: height * 0.03,
          ),
          Text(
            AppStrings.enterPin,
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: height * 0.05),
          Container(
            width: width * 0.80,
            child:
            Form(
              key: _formKey,
              child: GestureDetector(
                onLongPress: () {},
                child: PinPut(
                  controller: pinPutController,
                  validator: validatePinput,
                  autovalidateMode: AutovalidateMode.disabled,
                  withCursor: true,
                  fieldsCount: 4,
                  fieldsAlignment: MainAxisAlignment.spaceAround,
                  textStyle:
                  const TextStyle(fontSize: 25.0, color: Colors.black),
                  eachFieldMargin: EdgeInsets.all(0),
                  eachFieldWidth: 20.0,
                  eachFieldHeight: 25.0,
                  onSubmit: (String pin) async {
                    FocusScope.of(context).unfocus();

                    ///after submitting pin keyboard will automatically destroy.
                    if (_formKey.currentState.validate()) {
                      var verify;
                      await _checkInternet();
                      if (isInternetAvailable == true) {
                        showLoadingDialog(context, _keyLoader);
                        BlocProvider.of<PinScreenBloc>(context)
                            .add(PinScreenEvent(
                          pin,
                          verify,
                        ));
                        print("this is pinPut value $pinPutController");
                      }else if(isInternetAvailable == false){
                        _validateOffLine();
                      }
                    }
                  },
                  submittedFieldDecoration: pinPutDecoration,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  selectedFieldDecoration: pinPutDecoration.copyWith(
                    color: Colors.white,
                    border: Border.all(
                      width: 2,
                      color: const Color.fromRGBO(160, 215, 220, 1),
                    ),
                  ),
                  followingFieldDecoration: pinPutDecoration,
                  pinAnimationType: PinAnimationType.slide,
                ),
              ),
            ),
          ),
          SizedBox(
            height: height * 0.10,
          ),
          GestureDetector(
            onTap: () async {
              SharedPreferences preferences =
              await SharedPreferences.getInstance();
              await preferences.clear();
              MySharedPreferences.instance.removeAll();
              RouteGenerator.navigatorKey.currentState
                  .pushReplacementNamed(LoginScreen.routeName);
            },
            child: Text(
              AppStrings.loginWithDiffAcc,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  decoration: TextDecoration.underline),
            ),
          ),
          SizedBox(
            height: height * 0.02,
          ),
          GestureDetector(
            onTap: () async {
              if (await _isBiometricAvailable()) {
                await _getListOfBiometricTypes();
                await _authenticateUser();
              }
            },
            child: Text(
              AppStrings.userTouchAndFaceId,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          SizedBox(
            height: 25,
          ),
        ]),
      ),
    );
  }
}