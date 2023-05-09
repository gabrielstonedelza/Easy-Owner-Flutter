import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../constants.dart';
import '../../../widget/loadingui.dart';
import 'momodepositsummarydetail.dart';


class MomoCashInSummary extends StatefulWidget {
  final username;
  const MomoCashInSummary({Key? key,required this.username}) : super(key: key);

  @override
  State<MomoCashInSummary> createState() => _MomoCashInSummaryState(username:this.username);
}

class _MomoCashInSummaryState extends State<MomoCashInSummary> {
  final username;
  _MomoCashInSummaryState({required this.username});
  double sum = 0.0;
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allMomoDeposits = [];
  var items;
  bool isLoading = true;
  late List amounts = [];
  late List bankAmounts = [];
  late List mtnDepositDates = [];

  fetchAllAgentsMtnDeposits()async{
    final url = "https://fnetagents.xyz/get_agents_momo_deposits/$username/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMomoDeposits = json.decode(jsonData);
      for(var i in allMomoDeposits){
        if(!mtnDepositDates.contains(i['date_deposited'].toString().split("T").first)){
          mtnDepositDates.add(i['date_deposited'].toString().split("T").first);
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
    fetchAllAgentsMtnDeposits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("$username's Mtn Deposit Summary"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading ? const LoadingUi() :
      ListView.builder(
          itemCount: mtnDepositDates != null ? mtnDepositDates.length : 0,
          itemBuilder: (context,i){
            items = mtnDepositDates[i];
            return Column(
              children: [
                const SizedBox(height: 10,),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return MtnDepositSummaryDetail(deposit_date:mtnDepositDates[i],username:username);
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
      //     Get.to(() => const CashIn());
      //   },
      // )
    );
  }
}
