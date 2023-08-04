import 'dart:convert';
import 'package:easy_owner/constants.dart';
import 'package:easy_owner/dashboard.dart';
import 'package:easy_owner/login.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../sendsms.dart';

class AgentController extends GetxController{
  late List allMyAgents = [];
  bool isLoading = true;
  final SendSmsController sendSms = SendSmsController();


  Future<void> getAllMyAgents(String token,String agentCode) async {
    try {
      isLoading = true;
      final completedRides = "https://fnetagents.xyz/get_all_my_agents/$agentCode";
      var link = Uri.parse(completedRides);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allMyAgents.assignAll(jsonData);

        update();
      }
    } catch (e) {
      Get.snackbar("Sorry","something happened or please check your internet connection");
    } finally {
      isLoading = false;
    }
  }

  addAgent(String email,String username,String fullName,String phoneNum,String password1,String password2,String ownerCode,String cName,String cNumber,String loc,String dAdd)async{
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
      "owner": ownerCode,
      "company_name": cName,
      "company_number": cNumber,
      "location": loc,
      "digital_address": dAdd,
      "user_approved": "True",
    });
    if (response.statusCode == 201) {
      String num = phoneNum.replaceFirst("0", '+233');
      sendSms.sendMySms(num, "EasyAgent","Hi $username,you have been registered on the Easy Agent portal,please login with these details.Username = $username and Password=$password1.Make sure to click on forgot password to reset it.");

      Get.snackbar("Hurray 😀", "Agent was added successfully",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground,
          duration: const Duration(seconds: 5));
      Get.offAll(() => const Dashboard());
      update();
    }
    else{
      Get.snackbar("Agent Error", response.body.toString(),
        duration: const Duration(seconds:10),
        colorText: defaultWhite,
        backgroundColor: warning,
      );
      return;
    }
  }

  registerOwner(String email,String username,String fullName,String phoneNum,String password1,String password2,String ownerCode,String cName,String cNumber,String loc,String dAdd,String abagCode)async{
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
      "user_type": "Owner",
      "owner": ownerCode,
      "company_name": cName,
      "company_number": cNumber,
      "location": loc,
      "digital_address": dAdd,
      "agent_code": abagCode,
    });
    if (response.statusCode == 201) {
      sendSms.sendMySms("+233244529353", "EasyAgent","Hi Mr Frank Fordjour,a new owner with the name  $fullName has registered on the Easy Portal,please login and check.");
      Get.snackbar("Hurray 😀", "your account was created successfully,however the admin would have to approve your account first",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground,
          duration: const Duration(seconds: 10));
      Get.offAll(() => const LoginView());
      update();
    }
    else{

      Get.snackbar("Account Error", "an owner with same details already exists or check your internet connection",
        duration: const Duration(seconds:5),
        colorText: defaultWhite,
        backgroundColor: warning,
      );
    }
  }

}