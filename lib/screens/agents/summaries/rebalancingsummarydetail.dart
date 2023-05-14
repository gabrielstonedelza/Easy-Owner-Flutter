import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../widget/loadingui.dart';


class ReBalancingSummaryDetail extends StatefulWidget {
  final date_requested;
  final username;
  const ReBalancingSummaryDetail({Key? key, this.date_requested,required this.username})
      : super(key: key);

  @override
  _ReBalancingSummaryDetailState createState() =>
      _ReBalancingSummaryDetailState(date_requested: this.date_requested,username:this.username);
}

class _ReBalancingSummaryDetailState extends State<ReBalancingSummaryDetail> {
  final date_requested;
  final username;
  _ReBalancingSummaryDetailState({required this.date_requested,required this.username});

  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allRequests = [];
  bool isLoading = true;
  late var items;
  late List amounts = [];
  late List amountResults = [];
  late List requestDates = [];
  double sum = 0.0;

  fetchAllRebalancing() async {
    final url = "https://fnetagents.xyz/get_user_re_balancing_requests/$username/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allRequests = json.decode(jsonData);
      for (var i in allRequests) {
        if (i['date_requested'].toString().split("T").first == date_requested) {
          requestDates.add(i);
          sum = sum + double.parse(i['amount']);
        }
      }
    }

    setState(() {
      isLoading = false;
      allRequests = allRequests;
      requestDates = requestDates;
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
    fetchAllRebalancing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: Text("Rebalancing summary for $date_requested"),
      ),
      body: SafeArea(
          child: isLoading
              ? const LoadingUi()
              : ListView.builder(
              itemCount: requestDates != null ? requestDates.length : 0,
              itemBuilder: (context, i) {
                items = requestDates[i];
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
                            title: buildRow("Amount: ", "amount"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                items["bank"] == "" ? Container():
                                buildRow("Bank: ", "bank"),
                                items["network"] == "" ? Container():
                                buildRow("Network: ", "network"),
                                items["account_number"] == "" ? Container():
                                buildRow("Account Number: ", "account_number"),
                                items["account_name"] == "" ? Container():
                                buildRow("Account Name: ", "account_name"),

                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0,top: 2),
                                  child: Row(
                                    children: [
                                      const Text("Date : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(items['date_requested'].toString().split("T").first, style: const TextStyle(
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
                                      Text(items['date_requested'].toString().split("T").last.toString().split(".").first, style: const TextStyle(
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
      floatingActionButton: !isLoading
          ? FloatingActionButton(
        backgroundColor: snackBackground,
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
}
