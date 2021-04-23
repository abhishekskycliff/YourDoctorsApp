import 'package:YOURDRS_FlutterAPP/blocs/login/login/login_bloc.dart';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
import 'package:YOURDRS_FlutterAPP/common/app_strings.dart';
import 'package:YOURDRS_FlutterAPP/common/app_toast_message.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/security_pin_screen/create_security_pin.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/security_pin_screen/verify_security_pin.dart';
import 'package:YOURDRS_FlutterAPP/utils/route_generator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<State> _keyLoader = GlobalKey<State>();

class LoginScreen extends StatefulWidget {
  static const String routeName = '/Login';
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginScreen> {
  /// declaring variable
  final _formKey = GlobalKey<FormState>();
  AppToast appToast = AppToast();
  bool _passwordVisible;
  var memberID;
  bool visible = false;
  bool isInternetAvailable = false;
  bool isPressed = true;

  /// Text editing Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// DialogBox to show the popup message if user credentials are wrong
  void _alertMessage() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppStrings.incorrectCredentials,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            AppStrings.wrongCredentialsMsg,
            style: TextStyle(
                color: CustomizedColors.your_doctors_text_color,
                fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppStrings.ok,
                style: TextStyle(
                    fontSize: 15,
                    color: CustomizedColors.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  ///checking internet connection available
  Future<void> _checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        isInternetAvailable = true;
      });
    } else {
      setState(() {
        isInternetAvailable = false;
      });
      //  appToast.showToast(AppStrings.no_internet);
      showInternetError(context, _keyLoader);
    }
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _checkInternet();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  ///customized loading indicator.
  Future<void> showLoadingDialog(BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  // backgroundColor: Colors.black54,
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

  Future<void> showInternetError(BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => true,
              child: SimpleDialog(
                key: key,
                // backgroundColor: Colors.redAccent.shade100,
                backgroundColor: Colors.white,
                children: <Widget>[
                  Center(
                    child: Column(children: [
                      Container(
                          height: 100,
                          child: Image.asset(
                            AppStrings.birdGif,
                            fit: BoxFit.cover,
                          )),
                      Text(
                        AppStrings.no_internet,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        AppStrings.checkConnection,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.normal),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Ok"),
                        style: ElevatedButton.styleFrom(
                          primary: CustomizedColors
                              .primaryColor, // background// foreground
                        ),
                      )
                    ]),
                  )
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, FormScreenState>(
      listener: (context, state) {
        // if the status code is true i.e 200 it execute the statement else go to next statement
        if (state.isTrue == true) {
          // checking for particular member pin is available or not.
          // based on that we are navigating user to respective screens.
          if (state.isPinAvailable == true) {
            // Route navigation to patientAppointment Screen
            Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                .pop(); //close the dialog
            RouteGenerator.navigatorKey.currentState.pushReplacementNamed(
                VerifyPinScreen.routeName,);
                // arguments: state.memberId);
          } else {
            // Route navigation to Create Pin Screen
            RouteGenerator.navigatorKey.currentState.pushReplacementNamed(
              CreatePinScreen.routeName,
            );
          }
        } else {
          setState(() {
            isPressed = true;
          });
          Navigator.of(_keyLoader.currentContext, rootNavigator: true)
              .pop(); //close the dialog
          _alertMessage();
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          child: Center(
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _text(),
                    _welcome_text(),
                    _yourdoctors_text(),
                    _form_field(),
                    _Signin_button(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Container for your doctor text with image
  @override
  Widget _text() {
    var height = MediaQuery.of(context).size.height;
    return Container(
      child: Row(
        // which add Row properties at the center
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.your,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: CustomizedColors.your_text_color),
          ),
          Text(
            AppStrings.doctors,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: CustomizedColors.doctor_text_color),
          ),
          Image.asset(
            AppImages.doctorImg,
            // I added asset image
            height: 60,
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: height * 0.1, top: height * 0.02),
    );
  }

  /// Container for welcome screen Text
  @override
  Widget _welcome_text() {
    var height = MediaQuery.of(context).size.height;
    return Container(
      child: Text(
        AppStrings.welcome_text,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 35,
              fontFamily: AppStrings.poppins,
              letterSpacing: 1),
        ),
      ),
      margin: EdgeInsets.only(bottom: height * 0.03),
    );
  }

  /// Container for your_doctors quote text
  @override
  Widget _yourdoctors_text() {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: height * 0.2,
          maxWidth: width * 0.9,
        ),
        child: Text(
          AppStrings.your_doctor_text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CustomizedColors.your_doctors_text_color),
        ),
      ),
      margin: EdgeInsets.only(bottom: height * 0.04),
    );
  }

  /// Two Form field to which validate the user input
  @override
  _form_field() {
    var height = MediaQuery.of(context).size.height;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: CustomizedColors.text_field_background,
              borderRadius: BorderRadius.circular(15),
            ),

            /// TextFormField for Email
            child: TextFormField(
              inputFormatters: [
                BlacklistingTextInputFormatter(RegExp(AppConstants.ignoreSpace))
                ///for disabling white spaces in form field
              ],
              validator: (value) {
                if (value.isEmpty) {
                  return AppStrings.enter_email;
                }
                return null;
              },
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 20),
                border: InputBorder.none,
                hintText: AppStrings.email_text_field_hint,
                hintStyle: TextStyle(fontWeight: FontWeight.w400),
              ),
            ),
            margin: EdgeInsets.only(
                left: height * 0.04,
                right: height * 0.04,
                top: height * 0.06,
                bottom: height * 0.05),
          ),
          Container(
            decoration: BoxDecoration(
              color: CustomizedColors.text_field_background,
              borderRadius: BorderRadius.circular(15),
            ),
            /// TextFormField for password
            child: TextFormField(
              inputFormatters: [
                BlacklistingTextInputFormatter(RegExp(AppConstants.ignoreSpace))

                ///for disabling white spaces in form field
              ],
              validator: (value) {
                if (value.isEmpty) {
                  return AppStrings.enter_password;
                }
                return null;
              },
              controller: passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 20, top: 15),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
                hintText: AppStrings.password_text_field_hint,
                hintStyle: TextStyle(fontWeight: FontWeight.w400),
              ),
            ),

            margin: EdgeInsets.only(
                left: height * 0.04,
                right: height * 0.04,
                bottom: height * 0.05),
          ),
        ],
      ),
    );
  }

  /// Onclick of sign in  Button user validated and navigated to next screen
  @override
  Widget _Signin_button() {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: CustomizedColors.text_field_background,
        borderRadius: BorderRadius.circular(10),
      ),
      width: width,
      height: 50,
      // ignore: deprecated_member_use
      child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          onPressed: isPressed
              ? () async {
                  //after submitting pin keyboard will automatically destroy.
                  FocusScope.of(context).unfocus();
                  //it will check for internet connection before sending data to Api.
                  await _checkInternet();
                  if (isInternetAvailable == true) {
                    if (_formKey.currentState.validate()) {
                      showLoadingDialog(context, _keyLoader);
                      setState(() {
                        ///to avoid multiple clicks on login button
                        isPressed = false;
                      });
                      BlocProvider.of<LoginBloc>(context).add(FormScreenEvent(
                          emailController.text, passwordController.text));
                    } else {
                      return null;
                    }
                  }
                }
              : () {},
          color: CustomizedColors.signInButtonColor,
          child: Text(
            AppStrings.sign_in,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: CustomizedColors.sign_in_text_color),
          )),
      margin: EdgeInsets.only(
          left: height * 0.04,
          right: height * 0.04,
          top: height * 0.05,
          bottom: height * 0.05),
    );
  }
}
