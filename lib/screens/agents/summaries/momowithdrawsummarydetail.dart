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

  late List accountBalanceDetailsToday = [];
  late List lastItem = [];
  late double physical = 0.0;
  late double mtn = 0.0;
  late double airteltigo = 0.0;
  late double vodafone = 0.0;
  late double mtnNow = 0.0;
  late double airtelTigoNow = 0.0;
  late double vodafoneNow = 0.0;
  late double physicalNow = 0.0;
  late double physicalNew = 0.0;
  late double mtnNew = 0.0;
  late double airteltigoNew = 0.0;
  late double vodafoneNew = 0.0;
  late double total = 0.0;

  Future<void>fetchAgentMtnWithdrawals()async{
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

  updateAndAddAccountsToday(String network,String agent) async {
    const accountUrl = "https://fnetagents.xyz/add_balance_to_start/";
    final myLink = Uri.parse(accountUrl);
    http.Response response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "physical":  physicalNow.toString(),
      "mtn_e_cash": network == "Mtn" ? mtnNew.toString() : mtnNow.toString(),
      "tigo_airtel_e_cash": network == "AirtelTigo"
          ? airteltigoNew.toString()
          : airtelTigoNow.toString(),
      "vodafone_e_cash": network == "Vodafone"
          ? vodafoneNew.toString()
          : vodafoneNow.toString(),
      "isStarted": "True",
      "agent": agent
    });
    if (response.statusCode == 201) {
      Get.snackbar("Success", "agent accounts was updated",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: secondaryColor);

    }
    else {
      // print(response.body);
      Get.snackbar("Account", "something happened",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
    }
  }

  Future<void> fetchAccountBalance() async {
    final postUrl =
        "https://fnetagents.xyz/get_my_agent_account_started_with/$username/";
    final pLink = Uri.parse(postUrl);
    http.Response res = await http.get(pLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var allPosts = jsonData;
      // print(res.body);
      accountBalanceDetailsToday.assignAll(allPosts);
      setState(() {
        isLoading = false;
        lastItem.assign(accountBalanceDetailsToday.last);
        physicalNow = double.parse(lastItem[0]['physical']);
        mtnNow = double.parse(lastItem[0]['mtn_e_cash']);
        airtelTigoNow = double.parse(lastItem[0]['tigo_airtel_e_cash']);
        vodafoneNow = double.parse(lastItem[0]['vodafone_e_cash']);
      });

    } else {
      // print(res.body);
    }
  }

  deleteWithdrawal(String id,String network,String agent) async {
    final url = "https://fnetagents.xyz/delete_agent_momo_withdrawals/$id";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 204) {
      fetchAgentMtnWithdrawals();
      updateAndAddAccountsToday(network,agent);
      Get.back();
    } else {

    }
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
    fetchAccountBalance();
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
                                      const Text("Date: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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
                              trailing: IconButton(
                                onPressed: (){
                                  if (items['network'] == "Mtn") {
                                    mtnNew = mtnNow + double.parse(withdrawalDates[i]['cash_paid']);

                                  } else if (items['network'] == "AirtelTigo") {
                                    airteltigoNew = airtelTigoNow + double.parse(withdrawalDates[i]['cash_paid']);

                                  } else if (items['network'] == "Vodafone") {
                                    vodafoneNew = vodafoneNow + double.parse(withdrawalDates[i]['cash_paid']);

                                  }
                                  deleteWithdrawal(withdrawalDates[i]['id'].toString(),withdrawalDates[i]['network'],withdrawalDates[i]['agent'].toString());
                                },
                                icon: const Icon(Icons.delete_forever,size: 30,color: warning,),
                              )
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
