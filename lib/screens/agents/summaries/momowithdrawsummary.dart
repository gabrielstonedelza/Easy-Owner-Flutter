import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../constants.dart';
import '../../../widget/loadingui.dart';
import 'momowithdrawsummarydetail.dart';


class MomoCashOutSummary extends StatefulWidget {
  final username;
  const MomoCashOutSummary({Key? key,required this.username}) : super(key: key);

  @override
  State<MomoCashOutSummary> createState() => _MomoCashOutSummaryState(username:this.username);
}

class _MomoCashOutSummaryState extends State<MomoCashOutSummary> {
  final username;
  _MomoCashOutSummaryState({required this.username});
  double sum = 0.0;
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allMomoWithdrawals = [];
  var items;
  bool isLoading = true;
  late List amounts = [];
  late List bankAmounts = [];
  late List mtnWithdrawalsDates = [];

  fetchAllAgentsMtnWithdrawals()async{
    final url = "https://fnetagents.xyz/get_agents_momo_withdrawals/$username/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMomoWithdrawals = json.decode(jsonData);
      for(var i in allMomoWithdrawals){
        if(!mtnWithdrawalsDates.contains(i['date_of_withdrawal'].toString().split("T").first)){
          mtnWithdrawalsDates.add(i['date_of_withdrawal'].toString().split("T").first);
        }
      }
    }

    setState(() {
      isLoading = false;
    });
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
    fetchAllAgentsMtnWithdrawals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("$username's Mtn Withdrawal Summary"),
          backgroundColor: secondaryColor,
        ),
        body: isLoading ? const LoadingUi() :
        ListView.builder(
            itemCount: mtnWithdrawalsDates != null ? mtnWithdrawalsDates.length : 0,
            itemBuilder: (context,i){
              items = mtnWithdrawalsDates[i];
              return Column(
                children: [
                  const SizedBox(height: 20,),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return MtnWithdrawalSummaryDetail(date_of_withdrawal:mtnWithdrawalsDates[i],username:username);
                      }));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0,right: 8),
                      child: Card(
                        color: secondaryColor,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        // shadowColor: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0,bottom: 5),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                children: [
                                  const Text("Date: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  Text(items,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
        ),
        // floatingActionButton:FloatingActionButton(
        //   backgroundColor: secondaryColor,
        //   child: const Icon(Icons.add,size: 30,),
        //   onPressed: (){
        //     Get.to(() => const CashOut());
        //   },
        // )
    );
  }
}
