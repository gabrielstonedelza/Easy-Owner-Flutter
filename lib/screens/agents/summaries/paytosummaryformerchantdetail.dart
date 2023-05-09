import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../widget/loadingui.dart';


class PayToMerchantSummaryDetail extends StatefulWidget {
  final username;
  final date_added;
  const PayToMerchantSummaryDetail({Key? key, this.date_added,required this.username})
      : super(key: key);

  @override
  _PayToMerchantSummaryDetailState createState() =>
      _PayToMerchantSummaryDetailState(date_added: this.date_added,username:this.username);
}

class _PayToMerchantSummaryDetailState extends State<PayToMerchantSummaryDetail> {
  final date_added;
  final username;
  _PayToMerchantSummaryDetailState({required this.date_added,required this.username});
  // late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allBalancing = [];
  bool isLoading = true;
  late var items;
  late List date_added_for_merchant = [];
  late List allPayToForMerchants = [];
  double sum = 0.0;

  fetchAllPayTo()async{
    final url = "https://fnetagents.xyz/get_agents_momo_pay_to/$username/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allPayToForMerchants = json.decode(jsonData);

      for(var i in allPayToForMerchants){
        if(i['pay_to_type'] == "Merchant"){
          if (i['date_added'].toString().split("T").first == date_added) {
            date_added_for_merchant.add(i);
            sum = sum + double.parse(i['amount']);
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

    if (storage.read("token") != null) {
      setState(() {
        hasToken = true;
        uToken = storage.read("token");
      });
    }
    fetchAllPayTo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: Text("Details for $date_added"),
      ),
      body: SafeArea(
          child: isLoading
              ? const LoadingUi()
              : ListView.builder(
              itemCount: date_added_for_merchant != null ? date_added_for_merchant.length : 0,
              itemBuilder: (context, i) {
                items = date_added_for_merchant[i];
                return Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Card(
                        color: secondaryColor,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        // shadowColor: Colors.pink,
                        child: Padding(
                          padding:
                          const EdgeInsets.only(top: 18.0, bottom: 18),
                          child: ListTile(
                            title: buildRow("Customer: ", "customer"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildRow("Amount : ", "amount"),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0,top: 2),
                                  child: Row(
                                    children: [
                                      const Text("Date : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(items['date_added'].toString().split("T").first, style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0,top: 2),
                                  child: Row(
                                    children: [
                                      const Text("Time : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(items['date_added'].toString().split("T").last.toString().split(".").first, style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              })),
      floatingActionButton: !isLoading
          ? FloatingActionButton(
        backgroundColor: snackBackground,
        child: const Text("Total"),
        onPressed: () {
          Get.defaultDialog(
            buttonColor: secondaryColor,
            title: "Total",
            middleText: "$sum",
            confirm: RawMaterialButton(
                shape: const StadiumBorder(),
                fillColor: secondaryColor,
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                )),
          );
        },
      )
          : Container(),
    );
  }

  Padding buildRow(String mainTitle,String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(mainTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(items[subtitle].toString(), style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
