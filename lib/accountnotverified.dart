import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class AccountNotApproved extends StatefulWidget {
  const AccountNotApproved({Key? key}) : super(key: key);

  @override
  State<AccountNotApproved> createState() => _AccountNotApprovedState();
}

class _AccountNotApprovedState extends State<AccountNotApproved> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset("assets/images/136192-rejected.json"),
          const Padding(
            padding: EdgeInsets.all(18.0),
            child: Center(
              child: Text("Sorry,the administrator hasn't approved your account yet,please kindly wait.",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
            ),
          ),
          const Center(
            child: Text("Thank you.",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
          ),
        ],
      ),
    );
  }
}
