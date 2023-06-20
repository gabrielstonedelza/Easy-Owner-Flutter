
import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_owner/widget/loadingui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'controller/authphonecontroller.dart';
import 'controller/logincontroller.dart';
import 'loginabout.dart';
import 'ownerregistration.dart';


class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController controller = Get.find();
  bool isObscured = true;
  final storage = GetStorage();
  late String uToken = "";

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController usernameController;
  late final TextEditingController _passwordController;
  FocusNode usernameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  final Uri _url = Uri.parse('https://fnetagents.xyz/password-reset/');
  final AuthPhoneController authController = Get.find();
  late List authPhoneDetails = [];
  late List authPhoneDetailsForAgent = [];
  late String phoneModel = "";
  late String phoneId = "";
  late String phoneBrand = "";
  late String phoneFingerprint = "";
  bool isDeUser = false;
  bool canLogin = false;
  bool isLoading = false;
  late List appVersions = [];
  late int appVersion = 0;
  late int latestAppVersion = 0;

  Future<void> fetchDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    phoneModel = androidInfo.model;
    phoneId = androidInfo.id;
    phoneBrand = androidInfo.brand;
    phoneFingerprint = androidInfo.fingerprint;
  }

  Future<void> fetchAuthPhone() async {
    const postUrl = "https://fnetagents.xyz/get_all_auth_phones/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      authPhoneDetails.assignAll(allPosts);

      setState(() {
        isLoading = false;
      });
    } else {
      // print(res.body);
    }
  }
  Future<void> fetchAgentAuthPhone() async {
    final postUrl = "https://fnetagents.xyz/get_all_auth_phone_agent_by_phone_id/$phoneId/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      authPhoneDetailsForAgent.assignAll(allPosts);
      setState(() {
        isLoading = false;
      });
      for(var i in authPhoneDetailsForAgent){
        if(authPhoneDetailsForAgent.isNotEmpty && i['get_agent_username'] == usernameController.text.trim() && i['finger_print'] == phoneFingerprint && i['phone_id'] == phoneId){
          setState(() {
            canLogin = true;
          });
        }
        if(i['get_agent_username'] != usernameController.text.trim() && i['finger_print'] == phoneFingerprint && i['phone_id'] == phoneId){
          setState(() {
            canLogin = false;
          });
          Get.snackbar("Device Auth Error 😝😜🤪", "This device is registered to another user,please use another device,thank you.",
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              backgroundColor: warning,
              duration: const Duration(seconds: 10));
          Get.offAll(() => const LoginView());
        }
      }
    }
  }

  Future<void> getLatestAppVersion() async {
    const url = "https://fnetagents.xyz/check_app_version/";
    var link = Uri.parse(url);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      appVersions.assignAll(jsonData);
      for(var i in appVersions){
        appVersion = i['app_version'];
        storage.write("AppVersion",appVersion.toString());
      }
      setState(() {
        isLoading = false;
      });

    }
  }


  Future<void> _launchInBrowser() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  bool isPosting = false;

  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    _passwordController = TextEditingController();
    controller.getAllSupervisors();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    authController.fetchAuthPhone(uToken);
    fetchDeviceInfo();
    fetchAuthPhone();
    getLatestAppVersion();
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: TextButton(
              onPressed: (){
                Get.to(() => const OwnerRegistration());
              },
              child: const Text("Register",style: TextStyle(color: secondaryColor,fontSize: 18,fontWeight: FontWeight.bold),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: TextButton(
              onPressed: (){
                Get.to(() => const LoginAboutPage());
              },
              child: const Text("About",style: TextStyle(color: secondaryColor,fontSize: 18,fontWeight: FontWeight.bold),),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 60,),
          Image.asset(
            "assets/images/forapp.png",
            width: 100,
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: usernameController,
                      focusNode: usernameFocusNode,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: buildInputDecoration("Username"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter username";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length > 1){
                          fetchAgentAuthPhone();
                        }
                      },
                      controller: _passwordController,
                      focusNode: passwordFocusNode,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorColor: secondaryColor,
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: secondaryColor),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscured = !isObscured;
                              });
                            },
                            icon: Icon(
                              isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: secondaryColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: secondaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.text,
                      obscureText: isObscured,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter password";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  isPosting  ? const LoadingUi() :
                  NeoPopTiltedButton(
                    isFloating: true,
                    onTapUp: () {
                      _startPosting();
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        controller.loginUser(usernameController.text.trim(),
                          _passwordController.text.trim(),);
                      }
                    },
                    decoration: const NeoPopTiltedButtonDecoration(
                      color: secondaryColor,
                      plunkColor: secondaryColor,
                      shadowColor: Color.fromRGBO(36, 36, 36, 1),
                      showShimmer: true,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 70.0,
                        vertical: 15,
                      ),
                      child: Text('Login',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () async{
                await _launchInBrowser();
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(color: secondaryColor,fontSize: 18,fontWeight: FontWeight.bold),
              )),

        ],
      ),
    );
  }

  InputDecoration buildInputDecoration(String text) {
    return InputDecoration(
      labelStyle: const TextStyle(color: secondaryColor),
      labelText: text,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: secondaryColor, width: 2),
          borderRadius: BorderRadius.circular(12)),
    );
  }
}
