import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:easy_owner/constants.dart';
import 'package:flutter/material.dart';

import '../../../getonlineimage.dart';
import '../../../widget/loadingui.dart';
import '../../commissions.dart';
import '../agentscustomers.dart';
import '../summaries/agentaccountsummary.dart';
import '../summaries/bankdepositsummary.dart';
import '../summaries/bankwithdrawalsummary.dart';
import '../summaries/momocashinsummary.dart';
import '../summaries/momowithdrawsummary.dart';
import '../summaries/paymentsummary.dart';
import '../summaries/paytosummary.dart';
import '../summaries/rebalancingsummary.dart';
import '../summaries/requestsummary.dart';

class AgentDetails extends StatefulWidget {
  final username;

  const AgentDetails({Key? key, required this.username}) : super(key: key);


  @override
  State<AgentDetails> createState() =>
      _AgentDetailsState(username: this.username);
}

class _AgentDetailsState extends State<AgentDetails> {
  final username;
  _AgentDetailsState({required this.username});
  final storage = GetStorage();
  late String uToken = "";
  late String agentCode = "";
  bool isLoading = true;
  late List agentCustomers = [];
  late List agentBankDeposits = [];
  late List agentBankWithdraws = [];
  late List agentMomoCashIns = [];
  late List agentMomoCashOuts = [];
  late List agentMomoPayTos = [];


  Future<void> getAllAgentCustomers() async {
    final url = "https://fnetagents.xyz/get_agents_customers/$username/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      agentCustomers = json.decode(jsonData);
      setState(() {
        isLoading = false;
      });
    }
    else{
      if (kDebugMode) {
        print(response.body);
      }
    }
  }
  Future<void> getAllAgentBankDeposits() async {
    final url = "https://fnetagents.xyz/get_agents_bank_deposits/$username/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      agentBankDeposits = json.decode(jsonData);
    }
    else{
      if (kDebugMode) {
        print(response.body);
      }
    }
  }
  Future<void> getAllAgentBankWithdraws() async {
    final url = "https://fnetagents.xyz/get_agents_bank_withdrawals/$username/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      agentBankWithdraws = json.decode(jsonData);
    }
    else{
      if (kDebugMode) {
        print(response.body);
      }
    }
  }
  Future<void> getAllAgentMoMoCashIns() async {
    final url = "https://fnetagents.xyz/get_agents_momo_deposits/$username/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      agentMomoCashIns = json.decode(jsonData);
    }
    else{
      if (kDebugMode) {
        print(response.body);
      }
    }
  }
  Future<void> getAllAgentMoMoCashOuts() async {
    final url = "https://fnetagents.xyz/get_agents_momo_withdrawals/$username/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      agentMomoCashOuts = json.decode(jsonData);
    }
    else{
      if (kDebugMode) {
        print(response.body);
      }
    }
  }
  Future<void> getAllAgentMoMoPayTos() async {
    final url = "https://fnetagents.xyz/get_agents_momo_pay_to/$username/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      agentMomoPayTos = json.decode(jsonData);
    }
    else{
      if (kDebugMode) {
        print(response.body);
      }
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

    getAllAgentCustomers();
    getAllAgentBankDeposits();
    getAllAgentBankWithdraws();
    getAllAgentMoMoCashIns();
    getAllAgentMoMoCashOuts();
    getAllAgentMoMoPayTos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details for $username"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading ? const LoadingUi() :ListView(
        children: [
          const SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      myOnlineImage("https://cdn-icons-png.flaticon.com/128/3201/3201521.png",70,70),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Customers"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => AgentCustomers(username: username,));
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      myOnlineImage("https://cdn-icons-png.flaticon.com/128/2830/2830289.png",70,70),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Bank Deposits"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => BankDepositSummary(username: username,));
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      myOnlineImage("https://cdn-icons-png.flaticon.com/128/2830/2830289.png",70,70),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Bank Withdrawals"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => BankWithdrawalSummary(username: username));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          const SizedBox(
            height: 10,
          ),
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
                    Get.to(() => MomoCashInSummary(username: username,));
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
                    Get.to(()=>MomoCashOutSummary(username:username));
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
                      const Text("Pay To"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => PayToSummary(username:username));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      myOnlineImage("https://cdn-icons-png.flaticon.com/128/9532/9532823.png",70,70),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Requests"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => RequestSummary(username: username,));
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      myOnlineImage("https://cdn-icons-png.flaticon.com/128/2331/2331941.png",70,70),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Payment"),
                    ],
                  ),
                  onTap: () {
                    Get.to(()=>PaymentSummary(username:username));
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      myOnlineImage("https://cdn-icons-png.flaticon.com/128/994/994377.png",70,70),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Rebalancing"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => RebalancingSummary(username:username));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      myOnlineImage("https://cdn-icons-png.flaticon.com/128/10318/10318009.png",70,70),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Accounts"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => AgentAccountSummaryDetail(username: username,));
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child:  Column(
                    children: [
                      myOnlineImage("https://cdn-icons-png.flaticon.com/128/2405/2405293.png",70,70),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Commission"),
                    ],
                  ),
                  onTap: () {
                    Get.to(()=>AgentCommissions(username:username));
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: const Column(
                    children: [
                      // Image.asset(
                      //   "assets/images/law.png",
                      //   width: 70,
                      //   height: 70,
                      // ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // const Text("Rebalancing"),
                    ],
                  ),
                  onTap: () {
                    // Get.to(() => RebalancingSummary(username:username));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
        ],
      ),
    );
  }
}
