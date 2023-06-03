import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../widget/loadingui.dart';


class MtnWithdrawalSummaryDetail extends StatefulWidget {
  final username;
  final date_of_withdrawal;
  const MtnWithdrawalSummaryDetail({Key? key,this.date_of_withdrawal,required this.username}) : super(key: key);

  @override
  _MtnWithdrawalSummaryDetailState createState() => _MtnWithdrawalSummaryDetailState(date_of_withdrawal: this.date_of_withdrawal,username:this.username);
}

class _MtnWithdrawalSummaryDetailState extends State<MtnWithdrawalSummaryDetail> {
  final date_of_withdrawal;
  final username;
  _MtnWithdrawalSummaryDetailState({required this.date_of_withdrawal,required this.username});
  // late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allMtnDeposits = [];
  bool isLoading = true;
  late var items;
  late List amounts = [];
  late List amountResults = [];
  late List withdrawalDates = [];
  double sum = 0.0;
  double amountReceived = 0.0;

  fetchAgentMtnWithdrawals()async{
    final url = "https://fnetagents.xyz/get_agents_momo_withdrawals/$username/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMtnDeposits = json.decode(jsonData);
      for(var i in allMtnDeposits){
        if(i['date_of_withdrawal'].toString().split("T").first == date_of_withdrawal){
          withdrawalDates.add(i);
          sum = sum + double.parse(i['cash_paid']);
          amountReceived = amountReceived + double.parse(i['amount_received']);
        }
      }
    }

    setState(() {
      isLoading = false;
      allMtnDeposits = allMtnDeposits;
      withdrawalDates = withdrawalDates;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(storage.read("token") != null){
      setState(() {
        hasToken = true;
        uToken = storage.read("token");
      });
    }
    fetchAgentMtnWithdrawals();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: Text("$username's Mtn Withdrawals"),
      ),
      body: SafeArea(
          child:
          isLoading ? const LoadingUi() : ListView.builder(
              itemCount: withdrawalDates != null ? withdrawalDates.length : 0,
              itemBuilder: (context,i){
                items = withdrawalDates[i];
                return Column(
                  children: [
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0,right: 8),
                      child: Card(
                        color: secondaryColor,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        // shadowColor: Colors.pink,
                        child:  Padding(
                          padding:
                          const EdgeInsets.only(top: 18.0, bottom: 18),
                          child: ListTile(
                            title: buildRow("Customer: ", "customer"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildRow("Amount: ", "cash_paid"),
                                buildRow("Amount Received: ", "amount_received"),
                                buildRow("Network: ", "network"),

                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0,top: 2),
                                  child: Row(
                                    children: [
                                      const Text("Date Deposited: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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
              }
          )
      ),
      floatingActionButton: !isLoading ? FloatingActionButton(
        backgroundColor: secondaryColor,
        child: const Text("Total"),
        onPressed: (){
          Get.defaultDialog(
            buttonColor: secondaryColor,
            title: "Total",
            content: Column(
              children: [
                Text("Amount Sent = $sum"),
                Text("Amount Received = $amountReceived"),
                Text("Commission = ${amountReceived - sum}"),
              ],
            ),
            middleText: "$sum",
            confirm: RawMaterialButton(
                shape: const StadiumBorder(),
                fillColor: secondaryColor,
                onPressed: (){
                  Get.back();
                }, child: const Text("Close",style: TextStyle(color: Colors.white),)),
          );
        },
      ):Container(),
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
