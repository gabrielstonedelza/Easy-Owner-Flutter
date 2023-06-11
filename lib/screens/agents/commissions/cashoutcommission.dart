
import 'dart:convert';
import 'package:easy_owner/constants.dart';
import 'package:easy_owner/widget/loadingui.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../summaries/momowithdrawsummary.dart';

class FetchCashOutCommissionMonthly extends StatefulWidget {
  final username;
  const FetchCashOutCommissionMonthly({Key? key,required this.username}) : super(key: key);

  @override
  State<FetchCashOutCommissionMonthly> createState() => _FetchCashOutCommissionMonthlyState(username:this.username);
}

class _FetchCashOutCommissionMonthlyState extends State<FetchCashOutCommissionMonthly> {
  final username;
  _FetchCashOutCommissionMonthlyState({required this.username});
  late final TextEditingController _searchMonth = TextEditingController();
  late final TextEditingController _searchYear= TextEditingController();
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
  double amountReceived = 0.0;
  var items;

  // fetchUserAccessBankByDate(String dMonth,String dYear)async{
  //   final url = "https://fnetghana.xyz/get_agents_access_bank_by_date/$username/$dMonth/$dYear/";
  //   var myLink = Uri.parse(url);
  //   final response = await http.get(myLink);
  //
  //   if(response.statusCode ==200){
  //     final codeUnits = response.body.codeUnits;
  //     var jsonData = const Utf8Decoder().convert(codeUnits);
  //     allTransactions = json.decode(jsonData);
  //     amounts.assignAll(allTransactions);
  //     for(var i in amounts){
  //       sum = sum + double.parse(i['amount']);
  //     }
  //     setState(() {
  //       hasData = true;
  //     });
  //   }
  //   else{
  //     setState(() {
  //       hasData = false;
  //     });
  //   }
  //
  //   setState(() {
  //     isSearching = false;
  //     allTransactions = allTransactions;
  //   });
  // }
  // fetchUserCalBankByDate(String dMonth,String dYear)async{
  //   final url = "https://fnetghana.xyz/get_agents_cal_bank_by_date/$username/$dMonth/$dYear/";
  //   var myLink = Uri.parse(url);
  //   final response = await http.get(myLink);
  //
  //   if(response.statusCode ==200){
  //     final codeUnits = response.body.codeUnits;
  //     var jsonData = const Utf8Decoder().convert(codeUnits);
  //     allTransactions = json.decode(jsonData);
  //     amounts.assignAll(allTransactions);
  //     for(var i in amounts){
  //       sum = sum + double.parse(i['amount']);
  //     }
  //     setState(() {
  //       hasData = true;
  //     });
  //   }
  //   else{
  //     setState(() {
  //       hasData = false;
  //     });
  //   }
  //
  //   setState(() {
  //     isSearching = false;
  //     allTransactions = allTransactions;
  //   });
  // }
  fetchAgentCashOutTransactionsByMonth()async{
    final url = "https://fnetagents.xyz/get_agents_cash_out_commission_by_monthly/$username/$bMonth/$bYear/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if(response.statusCode == 200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allTransactions = json.decode(jsonData);
      amounts.assignAll(allTransactions);
      for(var i in amounts){
        sum = sum + double.parse(i['cash_paid']);
        amountReceived = amountReceived + double.parse(i['amount_received']);
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
  // fetchUserFidelityBankByDate(String dMonth,String dYear)async{
  //   final url = "https://fnetghana.xyz/get_agents_fidelity_bank_by_date/$username/$dMonth/$dYear/";
  //   var myLink = Uri.parse(url);
  //   final response = await http.get(myLink);
  //
  //   if(response.statusCode ==200){
  //     final codeUnits = response.body.codeUnits;
  //     var jsonData = const Utf8Decoder().convert(codeUnits);
  //     allTransactions = json.decode(jsonData);
  //     amounts.assignAll(allTransactions);
  //     for(var i in amounts){
  //       sum = sum + double.parse(i['amount']);
  //     }
  //     setState(() {
  //       hasData = true;
  //     });
  //   }
  //   else{
  //     setState(() {
  //       hasData = false;
  //     });
  //   }
  //
  //   setState(() {
  //     isSearching = false;
  //     allTransactions = allTransactions;
  //   });
  // }
  // fetchUserGTBankByDate(String dMonth,String dYear)async{
  //   final url = "https://fnetghana.xyz/get_agents_gt_bank_by_date/$username/$dMonth/$dYear/";
  //   var myLink = Uri.parse(url);
  //   final response = await http.get(myLink);
  //
  //   if(response.statusCode ==200){
  //     final codeUnits = response.body.codeUnits;
  //     var jsonData = const Utf8Decoder().convert(codeUnits);
  //     allTransactions = json.decode(jsonData);
  //     amounts.assignAll(allTransactions);
  //     for(var i in amounts){
  //       sum = sum + double.parse(i['amount']);
  //     }
  //     setState(() {
  //       hasData = true;
  //     });
  //   }
  //   else{
  //     setState(() {
  //       hasData = false;
  //     });
  //   }
  //
  //   setState(() {
  //     isSearching = false;
  //     allTransactions = allTransactions;
  //   });
  // }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: secondaryColor,
          title: Text("$username's cash out commission"),
        ),
        body: ListView(
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
                    fetchAgentCashOutTransactionsByMonth();
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
              child:Column(
                children: [
                  const SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0,right: 8),
                    child: Card(
                      color: secondaryColor,
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      // shadowColor: Colors.pink,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18.0,bottom: 18),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text("Month: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(_currentSelectedMonth,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Year: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(_currentSelectedYear,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Commission: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  Text("Commission = ${amountReceived - sum}",style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: secondaryColor,
          onPressed: (){
            Get.to(() => MomoCashOutSummary(username: username,));
          },
          child: const Text("All"),
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
