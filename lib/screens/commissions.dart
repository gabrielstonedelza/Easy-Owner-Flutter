
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../constants.dart';
import 'agents/commissions/cashincommission.dart';
import 'agents/commissions/cashoutcommission.dart';



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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(storage.read("token") != null){
      setState(() {
        uToken = storage.read("token");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Get $username's Mtn Commission"),
        backgroundColor: secondaryColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
      )
    );
  }
}
