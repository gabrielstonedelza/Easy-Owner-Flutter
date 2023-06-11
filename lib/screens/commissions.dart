import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../constants.dart';
import '../widget/loadingui.dart';
import 'agents/commissions/cashincommission.dart';
import 'agents/commissions/cashoutcommission.dart';
import 'agents/commissionsummary/cashinsummarycommission.dart';



class AgentCommissions extends StatefulWidget {
  final username;
  const AgentCommissions({Key? key,required this.username}) : super(key: key);

  @override
  State<AgentCommissions> createState() => _AgentCommissionsState(username:this.username);
}

class _AgentCommissionsState extends State<AgentCommissions> {
  final username;
  _AgentCommissionsState({required this.username});
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";

  DateTime now = DateTime.now();
  // DateTime date = DateTime(now.year, now.month, now.day);
  late double totalCommission = 0.0;
  late double cashReceived = 0.0;
  late double cashOutReceived = 0.0;
  late double cashInTotal = 0.0;
  late double cashOutTotal = 0.0;
  late double cashInCommissionTotalForToday = 0.0;
  late double cashOutCommissionTotalForToday = 0.0;

  late List allMtnDeposits = [];
  late List allMtnWithdrawals = [];
  bool isLoading = true;
  late var items;
  late List amounts = [];
  late List amountResults = [];
  late List depositsDates = [];



  Future<void>fetchUserMtnDepositsForToday() async {
    final url = "https://fnetagents.xyz/get_agent_cash_in_commission_today/$username";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMtnDeposits = json.decode(jsonData);
      for (var i in allMtnDeposits) {
        cashInTotal = cashInTotal + double.parse(i['amount_sent']);
        cashReceived = cashReceived + double.parse(i['cash_received']);
        cashInCommissionTotalForToday =  cashReceived - cashInTotal;
      }
      setState(() {
        isLoading = false;
      });
    }

  }

  Future<void>fetchUserMtnWithdrawalsForToday()async{
    final url = "https://fnetagents.xyz/get_agent_cash_out_commission_today/$username";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMtnWithdrawals = json.decode(jsonData);
      for (var i in allMtnWithdrawals) {
        cashOutTotal = cashOutTotal + double.parse(i['cash_paid']);
        cashOutReceived = cashOutReceived + double.parse(i['amount_received']);
        cashOutCommissionTotalForToday = cashOutReceived - cashOutTotal;
      }
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(storage.read("token") != null){
      setState(() {
        uToken = storage.read("token");
      });
    }
    fetchUserMtnDepositsForToday();
    fetchUserMtnWithdrawalsForToday();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Get $username's Mtn Commission"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading ? const LoadingUi() :Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Center(
              child: Text("Today",style: TextStyle(fontWeight: FontWeight.bold),),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Total : ",style: TextStyle(fontWeight: FontWeight.bold,color: warning,fontSize: 20)),
                Text("${cashOutCommissionTotalForToday + cashInCommissionTotalForToday}",style: const TextStyle(fontWeight: FontWeight.bold,color: warning,fontSize: 20)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              height: 200,
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom:18.0),
                      child: Center(
                        child: Text("Cash In",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      ),
                    ),
                    Text("CashIn Total Today = $cashInTotal",style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Cash Received Total Today = $cashReceived",style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text("Commission for today is",style: TextStyle(fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.only(top:18.0),
                      child: Text("GHC $cashInCommissionTotalForToday",style: const TextStyle(fontWeight: FontWeight.bold,color: warning,fontSize: 20)),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              height: 200,
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 18.0),
                      child: Center(
                        child: Text("Cash Out",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      ),
                    ),
                    Text("CashOut Total Today = $cashOutTotal",style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Amount Received Total Today = $cashOutReceived",style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text("Commission for today is ",style: TextStyle(fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.only(top:18.0),
                      child: Text("GHC $cashOutCommissionTotalForToday",style: const TextStyle(fontWeight: FontWeight.bold,color: warning,fontSize: 20)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          const Divider(),
          const SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/momo.png",
                        width: 70,
                        height: 70,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Cash In"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => FetchCashInCommissionMonthly(username: username,));
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/momo.png",
                        width: 70,
                        height: 70,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Cash Out"),
                    ],
                  ),
                  onTap: () {
                    Get.to(()=>FetchCashOutCommissionMonthly(username:username));
                  },
                ),
              ),
            ],
          )
        ],
      ),

    );
  }
}
