import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AgentController extends GetxController{
  late List allMyAgents = [];
  bool isLoading = true;


  Future<void> getAllMyAgents(String token,String agent_code) async {
    try {
      isLoading = true;
      final completedRides = "https://fnetagents.xyz/get_all_my_agents/$agent_code";
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

}