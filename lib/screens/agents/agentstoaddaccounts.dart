import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../controller/agentcontroller.dart';
import '../../controller/profilecontroller.dart';
import '../../widget/loadingui.dart';
import 'addagentaccount.dart';


class MyAgentsToAddAccounts extends StatefulWidget {
  const MyAgentsToAddAccounts({Key? key}) : super(key: key);

  @override
  State<MyAgentsToAddAccounts> createState() => _MyAgentsToAddAccountsState();
}

class _MyAgentsToAddAccountsState extends State<MyAgentsToAddAccounts> {
  final AgentController controller = Get.find();
  final ProfileController profileController = Get.find();
  late String uToken = "";

  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allMyAgents = [];
  late Timer _timer;

  Future<void> getAllMyAgents() async {
    final completedRides = "https://fnetagents.xyz/get_all_my_agents/${profileController.ownersCode}";
    var link = Uri.parse(completedRides);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      allMyAgents.assignAll(jsonData);
      setState(() {
        isLoading = false;
      });
      // print(allMyAgents);
    }
  }


  @override
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    getAllMyAgents();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Agents"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading ? const LoadingUi() : ListView.builder(
          itemCount: allMyAgents != null ? allMyAgents.length : 0,
          itemBuilder: (context, i) {
            items = allMyAgents[i];
            return Card(
              color: secondaryColor,
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: (){
                  Get.to(()=>AgentAccountRegistration(agent:allMyAgents[i]['id'].toString(),username:allMyAgents[i]['username']));
                },
                title: buildRow("Name: ", "full_name"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow("Username : ", "username"),
                    buildRow("Phone : ", "phone_number"),
                    buildRow("Email : ", "email"),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0,bottom: 8,top: 8),
                      child: Text("Tap to add accounts",style: TextStyle(fontWeight: FontWeight.bold,color: snackBackground),),
                    )
                  ],
                ),
              ),
            );
          })
    );
  }

  Padding buildRow(String mainTitle, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            mainTitle,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            items[subtitle],
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
