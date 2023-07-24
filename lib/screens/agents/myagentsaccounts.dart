import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../controller/agentcontroller.dart';
import '../../widget/loadingui.dart';
import 'agentstoaddaccounts.dart';
import 'details/agenttransactions.dart';


class MyAgentsAccounts extends StatefulWidget {
  const MyAgentsAccounts({Key? key}) : super(key: key);

  @override
  State<MyAgentsAccounts> createState() => _MyAgentsAccountsState();
}

class _MyAgentsAccountsState extends State<MyAgentsAccounts> {
  final AgentController controller = Get.find();

  late String uToken = "";
  late String agentCode = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allMyAgentsAccounts = [];


  Future<void> getAllMyAgentsAccounts() async {
    try {
      isLoading = true;
      const completedRides = "https://fnetagents.xyz/get_my_agents_accounts_detail/";
      var link = Uri.parse(completedRides);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $uToken"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allMyAgentsAccounts.assignAll(jsonData);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      Get.snackbar("Sorry","something happened or please check your internet connection");
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
    if (storage.read("agent_code") != null) {
      setState(() {
        agentCode = storage.read("agent_code");
      });
    }
    getAllMyAgentsAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Agents Accounts"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading ? const LoadingUi() :ListView.builder(
          itemCount: allMyAgentsAccounts != null ? allMyAgentsAccounts.length : 0,
          itemBuilder: (context, i) {
            items = allMyAgentsAccounts[i];
            return Card(
              color: secondaryColor,
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(

                title: buildRow("Agent: ", "get_agent_username"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow("Bank: ", "bank"),
                    buildRow("Acc Name: ", "account_name"),
                    buildRow("Acc No: ", "account_number"),
                    buildRow("Phone : ", "phone"),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0,top: 2),
                      child: Row(
                        children: [
                          const Text("Date Added: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(items['date_added'].toString().split("T").first, style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

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
