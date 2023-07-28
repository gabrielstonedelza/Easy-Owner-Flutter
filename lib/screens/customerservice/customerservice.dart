
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../fraudsters.dart';
import '../../widget/basicui.dart';
import 'mycomplains.dart';
import 'myholdaccountsrequests.dart';


class CustomerService extends StatelessWidget {
  const CustomerService({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Service"),

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
                      Image.asset("assets/images/sad.png",width: 70,height: 70,),
                      const Padding(
                        padding: EdgeInsets.only(top:18.0),
                        child: Text("Complains",style: TextStyle(fontWeight: FontWeight.bold),),
                      )
                    ],
                  ),
                  onTap: () {
                    Get.to(()=> const MyComplains());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      // myBasicWidget("hold.png","Hold","Account"),
                      Image.asset("assets/images/hold.png",width: 70,height: 70,),
                      const Padding(
                        padding: EdgeInsets.only(top:8.0),
                        child: Text("Hold",style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top:8.0),
                        child: Text("Account",style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => const MyRequestToHoldAccounts());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/fraud.png",width: 70,height: 70,),
                      const Padding(
                        padding: EdgeInsets.only(top:18.0),
                        child: Text("Fraud",style: TextStyle(fontWeight: FontWeight.bold),),
                      )
                    ],
                  ),
                  onTap: () {
                    Get.to(() => const Fraud());
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
