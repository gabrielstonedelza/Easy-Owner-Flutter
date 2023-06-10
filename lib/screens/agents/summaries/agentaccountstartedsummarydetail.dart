import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../widget/loadingui.dart';


class AgentAccountStartedBalanceSummaryDetail extends StatefulWidget {
  final username;
  final date_posted;
  const AgentAccountStartedBalanceSummaryDetail({Key? key, this.date_posted,required this.username})
      : super(key: key);

  @override
  _AgentAccountStartedBalanceSummaryDetailState createState() =>
      _AgentAccountStartedBalanceSummaryDetailState(date_posted: this.date_posted,username:this.username);
}

class _AgentAccountStartedBalanceSummaryDetailState extends State<AgentAccountStartedBalanceSummaryDetail> {
  final date_posted;
  final username;
  _AgentAccountStartedBalanceSummaryDetailState({required this.date_posted,required this.username});
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allBalancing = [];
  late List reversedAccountBalanceToday = List.of(allBalancing.reversed);
  bool isLoading = true;
  late var items;
  late var itemsClosed;
  late List amounts = [];
  late List amountResults = [];
  late List balancingDates = [];
  double sum = 0.0;

  Future<void>fetchAllAccountBalance() async {
    final url = "https://fnetagents.xyz/get_my_agent_account_started_with/$username/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allBalancing = json.decode(jsonData);
      for (var i in allBalancing) {
        if (i['date_posted'].toString().split("T").first == date_posted) {
          balancingDates.add(i);
          sum = sum + double.parse(i['e_cash_total']);
        }
      }
    }

    setState(() {
      isLoading = false;
      allBalancing = allBalancing;
      balancingDates = balancingDates;
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
    fetchAllAccountBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: Text("Account for $date_posted"),
      ),
      body: SafeArea(
          child: isLoading
              ? const LoadingUi()
              : ListView.builder(
              reverse: true,
              itemCount: balancingDates != null ? balancingDates.length : 0,
              itemBuilder: (context, i) {
                items = balancingDates[i];
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
                            title: buildRow("Total: ", "e_cash_total"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildRow("Physical : ", "physical"),
                                buildRow("Mtn : ", "mtn_e_cash"),
                                buildRow("AirtelTigo : ", "tigo_airtel_e_cash"),
                                buildRow("Vodafone : ", "vodafone_e_cash"),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0,top: 2),
                                  child: Row(
                                    children: [
                                      const Text("Date : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(items['date_posted'].toString().split("T").first, style: const TextStyle(
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
                    ),
                  ],
                );
              })),
      floatingActionButton: !isLoading
          ? FloatingActionButton(
        backgroundColor: secondaryColor,
        child: const Text("Total"),
        onPressed: () {
          Get.defaultDialog(
            buttonColor: secondaryColor,
            title: "Total",
            middleText: "$sum",
            confirm: RawMaterialButton(
                shape: const StadiumBorder(),
                fillColor: secondaryColor,
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                )),
          );
        },
      )
          : Container(),
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

  Padding buildClosedRow(String mainTitle,String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(mainTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(itemsClosed[subtitle].toString(), style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
