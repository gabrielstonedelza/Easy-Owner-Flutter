import 'package:easy_owner/controller/profilecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';

import '../../constants.dart';
import '../../controller/agentcontroller.dart';
import '../../widget/loadingui.dart';


class AddNewAgent extends StatefulWidget {
  const AddNewAgent({Key? key}) : super(key: key);

  @override
  State<AddNewAgent> createState() => _AddNewAgentState();
}

class _AddNewAgentState extends State<AddNewAgent> {

  final AgentController agentController = Get.find();
  late final TextEditingController _usernameController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _companyNumberController;
  late final TextEditingController _locationController;
  late final TextEditingController _digitalAddressController;
  late final TextEditingController _emailController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _rePasswordController;
  late final TextEditingController _phoneNumberController;
  final ProfileController profileController = Get.find();

  final _formKey = GlobalKey<FormState>();
  bool isObscured = true;
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _companyNameFocusNode = FocusNode();
  final FocusNode _companyNumberFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _digitalAddressFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _rePasswordFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();

  final storage = GetStorage();
  late String username = "";
  late String uToken = "";
  late String userCode = "";
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
    // TODO: implement initState
    super.initState();

    if (storage.read("userToken") != null) {
      uToken = storage.read("userToken");
    }
    if (storage.read("agent_code") != null) {
      userCode = storage.read("agent_code");
    }

    _usernameController = TextEditingController();
    _companyNameController = TextEditingController();
    _companyNumberController = TextEditingController();
    _locationController = TextEditingController();
    _digitalAddressController = TextEditingController();
    _emailController = TextEditingController();
    _fullNameController = TextEditingController();
    _passwordController = TextEditingController();
    _rePasswordController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _companyNameController.dispose();
    _companyNumberController.dispose();
    _locationController.dispose();
    _digitalAddressController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    _phoneNumberController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add New Agent",),
          backgroundColor: secondaryColor,
          elevation: 0,
        ),
        body:  ListView(
          children: [
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
                        controller: _usernameController,
                        focusNode: _usernameFocusNode,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        cursorColor: secondaryColor,
                        decoration: buildInputDecoration("Username"),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter username";
                          }
                          if(value.length == 4){
                            Get.snackbar("Username error", "should be greater than 4",
                                colorText: defaultWhite,
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: warning,
                                duration: const Duration(seconds: 5));
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        cursorColor: secondaryColor,
                        decoration: buildInputDecoration("Email"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter email";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: _fullNameController,
                        focusNode: _fullNameFocusNode,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        cursorColor: secondaryColor,
                        decoration: buildInputDecoration("Full Name"),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter full name";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: _phoneNumberController,
                        focusNode: _phoneNumberFocusNode,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        cursorColor: secondaryColor,
                        decoration: buildInputDecoration("Phone Number"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter phone number";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: _companyNameController,
                        focusNode: _companyNameFocusNode,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        cursorColor: secondaryColor,
                        decoration: buildInputDecoration("Company Name"),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter company name";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: _companyNumberController,
                        focusNode: _companyNumberFocusNode,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        cursorColor: secondaryColor,
                        decoration: buildInputDecoration("Company Number"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter company number";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: _locationController,
                        focusNode: _locationFocusNode,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        cursorColor: secondaryColor,
                        decoration: buildInputDecoration("Location"),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter location";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: _digitalAddressController,
                        focusNode: _digitalAddressFocusNode,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        cursorColor: secondaryColor,
                        decoration: buildInputDecoration("Digital Add"),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter digital add";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        cursorColor: secondaryColor,
                        decoration: buildInputDecoration("Password"),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter password";
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        onChanged: (value){
                          if(value.length == _passwordController.text.length && value != _passwordController.text){
                            Get.snackbar("Password error", "your password don't match",
                                colorText: defaultWhite,
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: warning,
                                duration: const Duration(seconds: 5));
                          }
                          return;
                        },
                        controller: _rePasswordController,
                        focusNode: _rePasswordFocusNode,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        cursorColor: secondaryColor,
                        decoration: buildInputDecoration("Confirm Password"),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please reenter password";
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 30,),
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
                          agentController.addAgent(_emailController.text.trim(), _usernameController.text.trim(), _fullNameController.text.trim(), _phoneNumberController.text.trim(), _passwordController.text.trim(), _rePasswordController.text.trim(), profileController.ownersCode,_companyNameController.text.trim(),_companyNumberController.text.trim(),_locationController.text.trim(),_digitalAddressController.text.trim());
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
                        child: Text('Save',style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            )
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
