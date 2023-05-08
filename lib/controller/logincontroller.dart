import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../authenticatebyphone.dart';


class LoginController extends GetxController {
  final client = http.Client();
  final storage = GetStorage();
  bool isLoggingIn = false;
  bool isUser = false;
  late List allSupervisors = [];
  late List supervisorsCodes = [];
  late List supervisorsEmails = [];
  late int oTP = 0;
  late String myToken = "";

  String errorMessage = "";
  bool isLoading = false;



  Future<void> getAllSupervisors() async {
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
        for (var i in allSupervisors) {
          supervisorsCodes.add(i['agent_unique_code']);
        }
        update();
      }
    } catch (e) {
      Get.snackbar("Sorry",
          "something happened or please check your internet connection");
    } finally {
      isLoading = false;
    }
  }

  Future<void> loginUser(String agentCode, String password) async {
    const loginUrl = "https://fnetagents.xyz/auth/token/login/";
    final myLink = Uri.parse(loginUrl);
    http.Response response = await client.post(myLink,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"agent_unique_code": agentCode, "password": password});

    if (response.statusCode == 200) {
      final resBody = response.body;
      var jsonData = jsonDecode(resBody);
      var userToken = jsonData['auth_token'];

      storage.write("token", userToken);
      storage.write("agent_code", agentCode);
      isLoggingIn = false;
      isUser = true;

      if (supervisorsCodes.contains(agentCode)) {
        Get.offAll(() => const AuthenticateByPhone());
      } else {
        Get.snackbar(
            "Sorry 😢", "You are not an owner or you entered invalid details",
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        isLoggingIn = false;
        isUser = false;
      }
    } else {
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
