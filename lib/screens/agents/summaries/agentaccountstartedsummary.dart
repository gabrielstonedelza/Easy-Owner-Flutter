import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../constants.dart';
import '../../../widget/loadingui.dart';
import 'agentaccountstartedsummarydetail.dart';



class AgentAccountStartedBalanceSummary extends StatefulWidget {
  final username;
  const AgentAccountStartedBalanceSummary({Key? key,required this.username}) : super(key: key);

  @override
  State<AgentAccountStartedBalanceSummary> createState() => _AgentAccountStartedBalanceSummaryState(username:this.username);
}

class _AgentAccountStartedBalanceSummaryState extends State<AgentAccountStartedBalanceSummary> {
  final username;
  _AgentAccountStartedBalanceSummaryState({required this.username});
  double sum = 0.0;
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allBalanceStarted = [];
  var items;
  bool isLoading = true;
  late List amounts = [];
  late List accountDates = [];

  fetchAllAccountBalance()async{
    final url = "https://fnetagents.xyz/get_my_agent_account_started_with/$username";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allBalanceStarted = json.decode(jsonData);

      for(var i in allBalanceStarted){
        if(!accountDates.contains(i['date_posted'].toString().split("T").first)){
          accountDates.add(i['date_posted'].toString().split("T").first);
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
    fetchAllAccountBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Balance Summary"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading ? const LoadingUi() :
      ListView.builder(
          itemCount: accountDates != null ? accountDates.length : 0,
          itemBuilder: (context,i){
            items = accountDates[i];
            return Column(
              children: [
                const SizedBox(height: 10,),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return AgentAccountStartedBalanceSummaryDetail(date_posted:accountDates[i], username: username,);
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
      //     Get.to(() => const ReBalancing());
      //   },
      // )
    );
  }
}
