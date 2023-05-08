import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rv;
import 'package:agents_promotor_app/screens/dashboard.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;



class LoginController extends GetxController{
  final client = http.Client();
  late String username;
  late String password;
  final storage = GetStorage();
  bool isLoggingIn = false;
  bool isUser = false;
  bool isAuthenticatedAlready = false;
  late List allSupervisors = [];
  late List supervisorEmails = [];


  static LoginController get to => Get.find<LoginController>();

  String errorMessage = "";
  rv.StateMachineController? controller;
  rv.SMIInput<bool>? trigSuccess;
  rv.SMIInput<bool>? trigFail;
  bool isLoading = false;

  Future<void> getAllSupervisors() async{
    try {
      isLoading = true;
      const completedRides = "https://fnetagents.xyz/get_all_supervisors/";
      var link = Uri.parse(completedRides);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allSupervisors.assignAll(jsonData);
        for(var i in allSupervisors){
          supervisorEmails.add(i['email']);
        }
        update();
      }
    } catch (e) {
      Get.snackbar("Sorry",
          "something happened or please check your internet connection");
    }
    finally{
      isLoading = false;
    }
  }


  Future<void> loginUser(String email,String password) async{
    const loginUrl = "https://fnetagents.xyz/auth/token/login/";
    final myLink = Uri.parse(loginUrl);
    http.Response response = await client.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    }, body: {
      "email": email,
      "password": password
    });

    if(response.statusCode == 200){
      final resBody = response.body;
      var jsonData = jsonDecode(resBody);
      var userToken = jsonData['auth_token'];
      storage.write("token", userToken);
      isLoggingIn = false;
      isUser = true;
      trigSuccess?.change(true);

      if(supervisorEmails.contains(email)){
        Get.offAll(() => const DashBoard());
      }
      else{
        trigFail?.change(true);
        Get.snackbar("Sorry 😢", "You are not a supervisor or you entered invalid details",
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        isLoggingIn = false;
        isUser = false;
      }
    }
    else{
      trigFail?.change(true);
      Get.snackbar("Sorry 😢", "invalid details",
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      isLoggingIn = false;
      isUser = false;
    }
  }
}