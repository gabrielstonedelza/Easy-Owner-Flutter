import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../constants.dart';
import '../../../widget/loadingui.dart';


class AgentAccountSummaryDetail extends StatefulWidget {
  final username;
  const AgentAccountSummaryDetail({Key? key,required this.username})
      : super(key: key);

  @override
  _AgentAccountSummaryDetailState createState() =>
      _AgentAccountSummaryDetailState(username:this.username);
}

class _AgentAccountSummaryDetailState extends State<AgentAccountSummaryDetail> {

  final username;

  _AgentAccountSummaryDetailState({required this.username});
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allAgentAccounts = [];
  bool isLoading = true;
  late var items;


  fetchAllAgentsAccountDetails() async {
    final url = "https://fnetagents.xyz/get_agent_accounts_by_username/$username/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allAgentAccounts = json.decode(jsonData);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (storage.read("token") != null) {
      setState(() {
        hasToken = true;
        uToken = storage.read("token");
      });
    }
    fetchAllAgentsAccountDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text("Accounts"),
      ),
      body: SafeArea(
          child: isLoading
              ? const LoadingUi()
              : ListView.builder(
              itemCount: allAgentAccounts != null ? allAgentAccounts.length : 0,
              itemBuilder: (context, i) {
                items = allAgentAccounts[i];
                return Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Card(
                        color: secondaryColor,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        // shadowColor: Colors.pink,
                        child: Padding(
                          padding:
                          const EdgeInsets.only(top: 18.0, bottom: 18),
                          child: ListTile(
                            title: items['bank'] == "Mtn" || items['bank'] == "Vodafone" || items['bank'] == "AirtelTigo" ? buildRow("Phone: ", "account_number") : buildRow("Account No: ", "account_number"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildRow("Account Name: ", "account_name"),
                                items['bank'] == "Mtn" || items['bank'] == "Vodafone" || items['bank'] == "AirtelTigo" ?
                                buildRow("Network: ", "bank") : buildRow("Bank: ", "bank"),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0,top: 2),
                                  child: Row(
                                    children: [
                                      const Text("Date : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(items['date_added'].toString().split("T").first, style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0,top: 2),
                                  child: Row(
                                    children: [
                                      const Text("Time : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(items['date_added'].toString().split("T").last.toString().split(".").first, style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              })),
    );
  }

  Padding buildRow(String mainTitle,String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(mainTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(items[subtitle].toString(), style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
