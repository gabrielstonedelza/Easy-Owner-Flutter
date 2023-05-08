import 'dart:convert';

import 'package:agents_promotor_app/controllers/profilecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../screens/dashboard.dart';

class AgentsController extends GetxController{
  late List allMyAgents = [];
  bool isLoading = false;
  final ProfileController controller = Get.find();

  Future<void> fetchMyAgents(String token) async {
    try {
      const postUrl = "https://fnetagents.xyz/get_all_my_agents/";
      final pLink = Uri.parse(postUrl);
      http.Response res = await http.get(pLink, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        'Accept': 'application/json',
        "Authorization": "Token $token"
      });
      if (res.statusCode == 200) {
        final codeUnits = res.body;
        var jsonData = jsonDecode(codeUnits);
        var allPosts = jsonData;
        allMyAgents.assignAll(allPosts);
        update();
      } else {
        // print(res.body);
      }
    } catch (e) {
      // Get.snackbar("Sorry", "please check your internet connection");
    } finally {
      isLoading = false;
      update();
    }
  }

  addAgent(String email,String username,String fullName,String phoneNum,String password1,String password2)async{
    const requestUrl = "https://fnetagents.xyz/auth/users/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      // "Authorization": "Token $token"
    }, body: {
      "email": email,
      "username": username,
      "full_name": fullName,
      "phone_number": phoneNum,
      "password": password1,
      "re_password": password2,
      "user_type": "Agent",
      "supervisor": controller.userId,
    });
    if (response.statusCode == 201) {

      Get.snackbar("Hurray 😀", "Agent was added successfully",
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 5));
      Get.offAll(() => const DashBoard());
      update();
    }
    else{
      Get.snackbar("Agent Error", "Agent with same details already exists or check your internet connection",
        duration: const Duration(seconds:5),
        colorText: Colors.white,
        backgroundColor: primaryColor,
      );
    }
  }
}