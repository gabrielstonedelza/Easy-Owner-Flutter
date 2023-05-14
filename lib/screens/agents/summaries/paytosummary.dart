import 'dart:convert';
import 'package:easy_owner/screens/agents/summaries/paytoagentsummarydetail.dart';
import 'package:easy_owner/screens/agents/summaries/paytosummaryformerchantdetail.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../constants.dart';
import '../../../widget/loadingui.dart';



class PayToSummary extends StatefulWidget {
  final username;
  const PayToSummary({Key? key,required this.username}) : super(key: key);

  @override
  State<PayToSummary> createState() => _PayToSummaryState(username:this.username);
}

class _PayToSummaryState extends State<PayToSummary> {
  final username;
  _PayToSummaryState({required this.username});
  double sum = 0.0;
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allPayToForAgent = [];
  late List allPayToForMerchants = [];
  var items;
  var merchatItems;
  bool isLoading = true;
  late List date_added_for_agent = [];
  late List date_added_for_merchant = [];

  fetchAllAgentsPayTo()async{
    final url = "https://fnetagents.xyz/get_agents_momo_pay_to/$username/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allPayToForAgent = json.decode(jsonData);

      for(var i in allPayToForAgent){
        if(i['pay_to_type'] == "Agent"){
          if(!date_added_for_agent.contains(i['date_added'].toString().split("T").first)){
            date_added_for_agent.add(i['date_added'].toString().split("T").first);
          }
        }
        if(i['pay_to_type'] == "Merchant"){
          if(!date_added_for_merchant.contains(i['date_added'].toString().split("T").first)){
            date_added_for_merchant.add(i['date_added'].toString().split("T").first);
          }
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
    fetchAllAgentsPayTo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const LoadingUi() : DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: secondaryColor,
              bottom: TabBar(
                indicatorColor: snackBackground,
                tabs: [
                  Tab(
                    child: Column(
                    children: [
                       Text("Agents (${date_added_for_agent.length})",style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white)),
                    ],
                  ),),
                  Tab(child: Column(
                    children: [
                      Text("Merchants (${date_added_for_merchant.length})",style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white)),
                    ],
                  ),),
                ],
              ),
              title: Text("$username's Pay To Summary"),
            ),
            body: TabBarView(
              children: [
                ListView.builder(
                  itemCount: date_added_for_agent != null ? date_added_for_agent.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    items = date_added_for_agent[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 12,
                        color: secondaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: (){
                              Get.to(() => PayToAgentSummaryDetail(date_added:date_added_for_agent[index],username:username));
                            },
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text("Date :",style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,color: defaultWhite
                                )),
                                const SizedBox(width:10),
                                Text(items,style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,color: defaultWhite
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },),
                ListView.builder(
                  itemCount: date_added_for_merchant != null ? date_added_for_merchant.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    merchatItems = date_added_for_merchant[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 12,
                        color: secondaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: (){
                              Get.to(() => PayToMerchantSummaryDetail(date_added:date_added_for_merchant[index],username:username));
                            },
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text("Date :",style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,color: defaultWhite
                                )),
                                const SizedBox(width:10),
                                Text(merchatItems,style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,color: defaultWhite
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
