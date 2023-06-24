
import 'dart:convert';
import 'package:easy_owner/constants.dart';
import 'package:easy_owner/widget/loadingui.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../../controller/profilecontroller.dart';

class FetchCashInToCsvMonthly extends StatefulWidget {
  final username;
  const FetchCashInToCsvMonthly({Key? key,required this.username}) : super(key: key);

  @override
  State<FetchCashInToCsvMonthly> createState() => _FetchCashInToCsvMonthlyState(username:this.username);
}

class _FetchCashInToCsvMonthlyState extends State<FetchCashInToCsvMonthly> {
  final username;
  _FetchCashInToCsvMonthlyState({required this.username});
  bool bankSelected = false;

  var _currentSelectedMonth = "1";
  var _currentSelectedYear = "2023";
  final _formKey = GlobalKey<FormState>();

  late List searchedTransactions = [];
  List months = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12"
  ];
  List years = [
    "2021",
    "2022",
    "2023",
    "2024",
    "2025",
    "2026",
    "2027",
    "2028",
    "2029",
    "2030",
  ];

  String bMonth = "";
  String bYear = "";

  late List allTransactions = [];
  bool isSearching = false;
  late List amounts = [];
  late List amountResults = [];
  bool hasData = false;
  double sum = 0.0;
  double cashReceived = 0.0;
  var items;
  final ProfileController controller = Get.find();
  bool isSendingEmail = false;


  Future<void>fetchAgentCashInTransactionsByMonth()async{
    final url = "https://fnetagents.xyz/get_agents_cash_in_commission_by_monthly/$username/$bMonth/$bYear/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if(response.statusCode == 200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allTransactions = json.decode(jsonData);
      amounts.assignAll(allTransactions);
      for(var i in amounts){
        sum = sum + double.parse(i['amount_sent']);
        cashReceived = cashReceived + double.parse(i['cash_received']);
      }
      setState(() {
        hasData = true;
        isSearching = false;
      });
    }
    else{
      setState(() {
        hasData = false;
        isSearching = false;
      });
    }
  }

  Future<void>sendTransactionDetailsToMail()async{
    final url = "https://fnetagents.xyz/export_momo_cash_in_transactions_csv/$username/$bMonth/$bYear/${controller.myEmail}/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if(response.statusCode == 200){
      setState(() {
        isSendingEmail = false;
      });
      Get.snackbar("Success 😀", "Transaction details have been sent to your email",
          duration: const Duration(seconds: 10),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: secondaryColor,
          colorText: Colors.white);
    }
    else{
      if (kDebugMode) {
        print(response.body);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: secondaryColor,
          title: Text("$username's cash in transaction"),
        ),
        body:isSendingEmail ? const LoadingUi() : ListView(
          children: [
            const SizedBox(height:20),
            const Padding(
                padding: EdgeInsets.only(left:35.0),
                child: Row(
                  children: [
                    Expanded(child: Text("Month",style:TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Year",style:TextStyle(fontWeight: FontWeight.bold))),
                  ],
                )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10),
                            child: DropdownButton(
                              hint: const Text("Month"),
                              isExpanded: true,
                              underline: const SizedBox(),
                              // style: const TextStyle(
                              //     color: Colors.black, fontSize: 20),
                              items: months.map((dropDownStringItem) {
                                return DropdownMenuItem(
                                  value: dropDownStringItem,
                                  child: Text(dropDownStringItem),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                _onDropDownItemSelectedMonth(newValueSelected);
                              },
                              value: _currentSelectedMonth,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10),
                            child: DropdownButton(
                              hint: const Text("Years"),
                              isExpanded: true,
                              underline: const SizedBox(),
                              // style: const TextStyle(
                              //     color: Colors.black, fontSize: 20),
                              items: years.map((dropDownStringItem) {
                                return DropdownMenuItem(
                                  value: dropDownStringItem,
                                  child: Text(dropDownStringItem),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                _onDropDownItemSelectedYear(newValueSelected);
                              },
                              value: _currentSelectedYear,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RawMaterialButton(
                onPressed: () {
                  setState(() {
                    isSearching = true;
                    bMonth = _currentSelectedMonth;
                    bYear = _currentSelectedYear;
                  });

                  if (!_formKey.currentState!.validate()) {
                    return;

                  } else {
                    fetchAgentCashInTransactionsByMonth();
                  }
                },
                // child: const Text("Send"),
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                        8)),
                elevation: 8,
                fillColor:
                secondaryColor,
                splashColor:
                defaultWhite,
                child: const Text(
                  "Search",
                  style: TextStyle(
                      fontWeight:
                      FontWeight
                          .bold,
                      fontSize: 20,
                      color:
                      defaultWhite),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            isSearching ? const LoadingUi() :
            SizedBox(height: MediaQuery.of(context).size.height,
              child:ListView.builder(
                itemCount: amounts != null ? amounts.length :0,
                  itemBuilder: (context,index){
                  items = amounts[index];
                  return Card(
                    color: secondaryColor,
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(top:8.0,bottom:8),
                        child: Row(
                          children: [
                            const Text("Agent : ",style: TextStyle(
                            fontWeight:
                            FontWeight
                            .bold,
                            fontSize:15,
                            color:
                            defaultWhite),),
                            Text(items['get_agent_username'],style: const TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold,
                                fontSize:15,
                                color:
                                defaultWhite),),
                          ],
                        ),
                      ),
                      subtitle:  Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top:8.0,bottom:8),
                            child: Row(
                              children: [
                                const Text("Customer : ",style: TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                                Text(items['customer'],style: const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                              ],
                            ),
                          ),
                          items['depositor_name'] == "" ? Container() : Padding(
                            padding: const EdgeInsets.only(top:8.0,bottom:8),
                            child: Row(
                              children: [
                                const Text("Depositor : ",style: TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                                Text(items['depositor_name'],style: const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                              ],
                            ),
                          ),
                         items['depositor_number'] == "" ? Container() : Padding(
                            padding: const EdgeInsets.only(top:8.0,bottom:8),
                            child: Row(
                              children: [
                                const Text("Depositor No: ",style: TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                                Text(items['depositor_number'],style: const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:8.0,bottom:8),
                            child: Row(
                              children: [
                                const Text("Network : ",style: TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                                Text(items['network'],style: const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:8.0,bottom:8),
                            child: Row(
                              children: [
                                const Text("Type : ",style: TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                                Text(items['type'],style: const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:8.0,bottom:8),
                            child: Row(
                              children: [
                                const Text("Amount Sent : ",style: TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                                Text(items['amount_sent'],style: const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:8.0,bottom:8),
                            child: Row(
                              children: [
                                const Text("Cash Received : ",style: TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                                Text(items['cash_received'],style: const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:8.0,bottom:8),
                            child: Row(
                              children: [
                                const Text("Date : ",style: TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                                Text(items['date_deposited'].toString().split("T").first,style: const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:8.0,bottom:8),
                            child: Row(
                              children: [
                                const Text("Time : ",style: TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                                Text(items['date_deposited'].toString().split("T").last.split(".").first,style: const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize:15,
                                    color:
                                    defaultWhite)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
              }),)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: secondaryColor,
          onPressed: (){
            setState(() {
              isSendingEmail = true;
            });
            sendTransactionDetailsToMail();
          },
          child: const Text("Save"),
        ),
      ),
    );
  }

  void _onDropDownItemSelectedMonth(newValueSelected) {
    setState(() {
      _currentSelectedMonth = newValueSelected;
    });
  }
  void _onDropDownItemSelectedYear(newValueSelected) {
    setState(() {
      _currentSelectedYear = newValueSelected;
    });
  }
}
