import 'dart:convert';
import 'package:easy_owner/constants.dart';
import 'package:easy_owner/dashboard.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AgentController extends GetxController{
  late List allMyAgents = [];
  bool isLoading = true;


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

  addAgent(String agentCode,String email,String username,String fullName,String phoneNum,String password1,String password2,String supervisorCode)async{
    const requestUrl = "https://fnetagents.xyz/auth/users/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      // "Authorization": "Token $token"
    }, body: {
      "agent_unique_code": agentCode,
      "email": email,
      "username": username,
      "full_name": fullName,
      "phone_number": phoneNum,
      "password": password1,
      "re_password": password2,
      "user_type": "Agent",
      "supervisor": supervisorCode,
      "user_approved": "True",
    });
    if (response.statusCode == 201) {

      Get.snackbar("Hurray 😀", "Agent was added successfully",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground,
          duration: const Duration(seconds: 5));
      Get.offAll(() => const Dashboard());
      update();
    }
    else{

      Get.snackbar("Agent Error", "Agent with same details already exists or check your internet connection",
        duration: const Duration(seconds:5),
        colorText: defaultWhite,
        backgroundColor: warning,
      );
    }
  }

}