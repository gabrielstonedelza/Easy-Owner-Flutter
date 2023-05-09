import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../widget/loadingui.dart';


class BankWithdrawalSummaryDetail extends StatefulWidget {
  final username;
  final date_of_withdrawal;
  const BankWithdrawalSummaryDetail({Key? key, this.date_of_withdrawal,required this.username})
      : super(key: key);

  @override
  _BankWithdrawalSummaryDetailState createState() =>
      _BankWithdrawalSummaryDetailState(date_of_withdrawal: this.date_of_withdrawal,username:this.username);
}

class _BankWithdrawalSummaryDetailState extends State<BankWithdrawalSummaryDetail> {
  final date_of_withdrawal;
  final username;
  _BankWithdrawalSummaryDetailState({required this.date_of_withdrawal,required this.username});
  // late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allBankWithdrawals = [];
  bool isLoading = true;
  late var items;
  late List amounts = [];
  late List amountResults = [];
  late List withdrawalDates = [];
  double sum = 0.0;

  fetchAllAgentsBankWithdrawals() async {
    final url = "https://fnetagents.xyz/get_agents_bank_withdrawals/$username/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allBankWithdrawals = json.decode(jsonData);
      for (var i in allBankWithdrawals) {
        if (i['date_of_withdrawal'].toString().split("T").first == date_of_withdrawal) {
          withdrawalDates.add(i);
          sum = sum + double.parse(i['amount']);
        }
      }
    }

    setState(() {
      isLoading = false;
      allBankWithdrawals = allBankWithdrawals;
      withdrawalDates = withdrawalDates;
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
    fetchAllAgentsBankWithdrawals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: Text("$username's Bank withdrawal for $date_of_withdrawal"),
      ),
      body: SafeArea(
          child: isLoading
              ? const LoadingUi()
              : ListView.builder(
              itemCount: withdrawalDates != null ? withdrawalDates.length : 0,
              itemBuilder: (context, i) {
                items = withdrawalDates[i];
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
                            title: buildRow("Customer: ", "customer"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildRow("Amount: ", "amount"),
                                buildRow("Bank: ", "bank"),
                                buildRow("Withdrawal Type : ", "withdrawal_type"),
                                items["d_200"] == 0 ? Container():
                                Row(
                                  children: [
                                    buildRow("200 GHC Notes: ", "d_200"),
                                    Text("(${items['d_200'] * 200})",style: const TextStyle(fontWeight: FontWeight.bold,color: snackBackground),)
                                  ],
                                ),
                                items["d_100"] == 0 ? Container():
                                Row(
                                  children: [
                                    buildRow("100 GHC Notes: ", "d_100"),
                                    Text("(${items['d_100'] * 100})",style: const TextStyle(fontWeight: FontWeight.bold,color: snackBackground),)
                                  ],
                                ),
                                items["d_50"] == 0 ? Container():
                                Row(
                                  children: [
                                    buildRow("50 GHC Notes: ", "d_50"),
                                    Text("(${items['d_50'] * 50})",style: const TextStyle(fontWeight: FontWeight.bold,color: snackBackground),)
                                  ],
                                ),
                                items["d_20"] == 0 ? Container():
                                Row(
                                  children: [
                                    buildRow("20 GHC Notes: ", "d_20"),
                                    Text("(${items['d_20'] * 20})",style: const TextStyle(fontWeight: FontWeight.bold,color: snackBackground),)
                                  ],
                                ),
                                items["d_10"] == 0 ? Container():
                                Row(
                                  children: [
                                    buildRow("10 GHC Notes: ", "d_10"),
                                    Text("(${items['d_10'] * 10})",style: const TextStyle(fontWeight: FontWeight.bold,color: snackBackground),)
                                  ],
                                ),
                                items["d_5"] == 0 ? Container():
                                Row(
                                  children: [
                                    buildRow("5 GHC Notes: ", "d_5"),
                                    Text("(${items['d_5'] * 5})",style: const TextStyle(fontWeight: FontWeight.bold,color: snackBackground),)
                                  ],
                                ),
                                items["d_2"] == 0 ? Container():
                                Row(
                                  children: [
                                    buildRow("2 GHC Notes: ", "d_2"),
                                    Text("(${items['d_2'] * 2})",style: const TextStyle(fontWeight: FontWeight.bold,color: snackBackground),)
                                  ],
                                ),
                                items["d_1"] == 0 ? Container():
                                Row(
                                  children: [
                                    buildRow("1 GHC Notes: ", "d_1"),
                                    Text("(${items['d_1'] * 1})",style: const TextStyle(fontWeight: FontWeight.bold,color: snackBackground),)
                                  ],
                                ),
                                buildRow("Total: ", "total",),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0,top: 2),
                                  child: Row(
                                    children: [
                                      const Text("Date : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(items['date_of_withdrawal'].toString().split("T").first, style: const TextStyle(
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
                                      Text(items['date_of_withdrawal'].toString().split("T").last.toString().split(".").first, style: const TextStyle(
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
