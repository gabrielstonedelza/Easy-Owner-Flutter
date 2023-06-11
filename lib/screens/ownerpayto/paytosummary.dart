import 'dart:convert';
import 'package:easy_owner/screens/ownerpayto/paytoagent.dart';
import 'package:easy_owner/screens/ownerpayto/paytoagentsummarydetails.dart';
import 'package:easy_owner/screens/ownerpayto/paytomerchant.dart';
import 'package:easy_owner/screens/ownerpayto/paytomerchantsummarydetail.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../constants.dart';
import '../../getonlineimage.dart';
import '../../widget/loadingui.dart';



class OwnerPayToSummary extends StatefulWidget {
  const OwnerPayToSummary({Key? key}) : super(key: key);

  @override
  State<OwnerPayToSummary> createState() => _OwnerPayToSummaryState();
}

class _OwnerPayToSummaryState extends State<OwnerPayToSummary> {
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

  fetchAllPayTo()async{
    const url = "https://fnetagents.xyz/get_all_owner_pay_to/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allPayToForAgent = json.decode(jsonData);
      // print(allPayToForAgent);

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
    fetchAllPayTo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const LoadingUi() : DefaultTabController(
        length: 2,
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
            title: const Text('Pay To Summary'),
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
                            Get.to(() => OwnerPayToAgentSummaryDetail(date_added:date_added_for_agent[index]));
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
                            Get.to(() => OwnerPayToMerchantSummaryDetail(date_added:date_added_for_merchant[index]));
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: secondaryColor,
            onPressed: (){
              showMaterialModalBottomSheet(
                context: context,
                builder: (context) => Card(
                  elevation: 12,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10))),
                  child: SizedBox(
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(
                            child: Text("Select",
                                style: TextStyle(
                                    fontWeight:
                                    FontWeight.bold))),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => const PayToAgent());
                                // Get.back();
                              },
                              child: Column(
                                children: [
                                  myOnlineImage("assets/images/employee.png",70,70),
                                  const Padding(
                                    padding: EdgeInsets.only(
                                        top: 10.0),
                                    child: Text("Agent",
                                        style: TextStyle(
                                            fontWeight:
                                            FontWeight.bold)),
                                  )
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                        () => const PayToMerchant());
                              },
                              child: Column(
                                children: [
                                  myOnlineImage("assets/images/cashier.png",70,70),
                                  const Padding(
                                    padding: EdgeInsets.only(
                                        top: 10.0),
                                    child: Text("Merchant",
                                        style: TextStyle(
                                            fontWeight:
                                            FontWeight.bold)),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: const Icon(Icons.add,size: 30,),
          ),
        ),
      ),
    );
  }
}
