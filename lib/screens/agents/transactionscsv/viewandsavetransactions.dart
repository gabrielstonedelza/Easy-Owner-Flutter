import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../getonlineimage.dart';
import 'bankdeposittransactiontocsv.dart';
import 'bankwithdrawaltransactiontocsv.dart';
import 'cashintransactioncsv.dart';
import 'cashouttransactioncsv.dart';

class ViewAndSaveTransactions extends StatefulWidget {
  final username;
  const ViewAndSaveTransactions({Key? key,required this.username}) : super(key: key);

  @override
  State<ViewAndSaveTransactions> createState() => _ViewAndSaveTransactionsState(username:this.username);
}

class _ViewAndSaveTransactionsState extends State<ViewAndSaveTransactions> {
  final username;
  _ViewAndSaveTransactionsState({required this.username});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("View and download transactions"),
          backgroundColor: secondaryColor,
        ),
      body: ListView(
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
                      myOnlineImage("assets/images/bank.png",50,50),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Bank"),
                      const Text("Deposits"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => FetchBankDepositToCsvMonthly(username: username,));
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      myOnlineImage("assets/images/bank.png",50,50),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Bank"),
                      const Text("Withdrawals"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => FetchBankWithdrawalToCsvMonthly(username: username));
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/momo.png",
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Cash In"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => FetchCashInToCsvMonthly(username: username,));
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/momo.png",
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Cash Out"),
                    ],
                  ),
                  onTap: () {
                    Get.to(()=>FetchCashOutToCsvMonthly(username:username));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
