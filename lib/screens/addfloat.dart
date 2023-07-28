
import 'package:easy_owner/controller/profilecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../dashboard.dart';
import '../widget/loadingui.dart';



class AddFloat extends StatefulWidget {
  const AddFloat({Key? key}) : super(key: key);

  @override
  State<AddFloat> createState() => _AddFloatState();
}

class _AddFloatState extends State<AddFloat> {
  final _formKey = GlobalKey<FormState>();

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



  late String uToken = "";
  final storage = GetStorage();

  late final TextEditingController floatRequestController;
  final ProfileController controller = Get.find();

  FocusNode floatRequestFocusNode = FocusNode();

  @override
  void initState(){
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    floatRequestController = TextEditingController();

  }

  @override
  void dispose(){
    super.dispose();
    floatRequestController.dispose();
  }


  addFloat()async{
    const registerUrl = "https://fnetagents.xyz/request_float/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "float_request": floatRequestController.text,
      "owner": controller.userId,
    });
    if(res.statusCode == 201){
      Get.snackbar("Congratulations", "float request sent",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
          backgroundColor: snackBackground);
      Get.offAll(()=>const Dashboard());
    }
    else{
      Get.snackbar("Error", "Something went wrong",
          colorText: defaultWhite,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Float"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      focusNode: floatRequestFocusNode,
                      controller: floatRequestController,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      maxLines: 5,
                      decoration: buildInputDecoration("Your Request"),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter request";
                        }
                        return null;
                      },
                    ),
                  ),

                  isPosting  ? const LoadingUi() :
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RawMaterialButton(
                      fillColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      onPressed: (){
                        _startPosting();
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        if (!_formKey.currentState!.validate()) {
                          return;
                        } else {

                          addFloat();
                        }
                      },child: const Text("Send",style: TextStyle(color: defaultWhite,fontWeight: FontWeight.bold),),
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