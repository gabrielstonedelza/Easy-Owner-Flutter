import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import '../constants.dart';
import '../controller/profilecontroller.dart';
import '../dashboard.dart';
import '../sendsms.dart';
import '../widget/loadingui.dart';


class GetMyAccountsAndPull extends StatefulWidget {
  const GetMyAccountsAndPull({Key? key}) : super(key: key);

  @override
  _GetMyAccountsAndPullState createState() => _GetMyAccountsAndPullState();
}

class _GetMyAccountsAndPullState extends State<GetMyAccountsAndPull> {

  late List allMyAccounts = [];
  bool isLoading = true;
  late List accountNames = [];
  late List accountLinkedNumbers = [];

  late String uToken = "";
  final storage = GetStorage();
  final List userBanks = [
    "Select bank",
  ];
  final List userAccounts = [
    "Select account number"
  ];
  var _currentAccountNumberSelected = "Select account number";

  final List agentAccountsNumbers = [];
  var _currentSelectedBank = "Select bank";
  var userDetailBanks = {};



  final SendSmsController sendSms = SendSmsController();
  bool isCustomer = false;
  bool isBank = false;
  bool isMobileMoney = false;
  late List myUser = [];
  late List deCustomer = [];
  bool isAccountNumberAndName = false;
  late String agentAccountName = "";
  late String agentAccountLinkedNumber = "";
  bool isFetching = false;
  bool bankSelected = false;
  bool fetchingAgentsAccounts = true;
  late String errorMessage = "";


  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _customerController;
  late final TextEditingController _depositorController;
  late final TextEditingController _idTypeController;
  late final TextEditingController _idNumberController;
  late final TextEditingController _agentAccountNameController;
  late final TextEditingController _agentLinkedNumController;
  bool isAboveFiveThousand = false;
  late List allUserRequests = [];
  late List amounts = [];

  bool accountNumberSelected = false;
  late List allAccountsWithPoints = [];
  late List accountsWithPoints = [];
  late List accountNumbers = [];
  final ProfileController controller = Get.find();

  Future<void>openOwnerFinancialServicesPullFromBank(String bankNum,String linkedNum,String amount) async {
    await UssdAdvanced.multisessionUssd(code: "*171*6*1*2*$bankNum*$linkedNum*$amount#", subscriptionId: 1);
  }

  Future<void> openFinancialServicesPullFromBank() async {
    await UssdAdvanced.multisessionUssd(code: "*171*6*1*2#", subscriptionId: 1);
  }

  Future<void>fetchUsersAccounts() async {
    const agentUrl = "https://fnetagents.xyz/get_my_user_accounts/";
    final agentLink = Uri.parse(agentUrl);
    http.Response res = await http.get(agentLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      myUser = jsonData;
      for(var i in myUser){
        if (!userBanks.contains(i['bank'])) {
          userBanks.add(i['bank']);
        }
        setState(() {
          fetchingAgentsAccounts = false;
          isLoading = false;
        });

      }
    }
    else{
      if (kDebugMode) {
        print(res.body);
      }
    }
  }
  Future<void>fetchCustomerBankAndNames(String deBank)async{
    final customerAccountUrl = "https://fnetagents.xyz/get_my_accounts_detail/${controller.phoneNumber}/$deBank/";
    final customerAccountLink = Uri.parse(customerAccountUrl);
    http.Response response = await http.get(customerAccountLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });
    if(response.statusCode == 200){
      final results = response.body;
      var jsonData = jsonDecode(results);
      deCustomer = jsonData;
      for(var cm in deCustomer){
        if(!userAccounts.contains(cm['account_number'])){
          userAccounts.add(cm['account_number']);
          accountNames.add(cm['account_name']);
          accountLinkedNumbers.add(cm['mtn_linked_number']);
        }
      }
      setState(() {
        isFetching = false;
      });
    }
    else{
      if (kDebugMode) {
        print(response.body);
      }
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    fetchUsersAccounts();

    _amountController = TextEditingController();
    _customerController = TextEditingController();
    _depositorController = TextEditingController();
    _idNumberController = TextEditingController();
    _agentAccountNameController = TextEditingController();
    _agentLinkedNumController = TextEditingController();
    _idTypeController = TextEditingController();

  }

  @override
  void dispose(){
    super.dispose();
    _customerController.dispose();
    _amountController.dispose();
    _depositorController.dispose();
    _idNumberController.dispose();
    _agentAccountNameController.dispose();
    _agentLinkedNumController.dispose();
    _idTypeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pull from Bank"),
        backgroundColor: secondaryColor,
      ),
      body:isLoading ? const LoadingUi() : ListView(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10,),

                  !fetchingAgentsAccounts ?
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select bank"),
                          isExpanded: true,
                          underline: const SizedBox(),
                          // style: const TextStyle(
                          //     color: Colors.black, fontSize: 20),
                          items: userBanks.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            fetchCustomerBankAndNames(newValueSelected.toString());
                            if(newValueSelected != "Select bank"){
                              fetchCustomerBankAndNames(newValueSelected.toString());
                              setState(() {
                                bankSelected = true;
                              });
                            }
                            // if(newValueSelected=="GT Bank"){
                            //   fetchCustomerBankAndNames("GT Bank");
                            //   setState(() {
                            //     bankSelected = true;
                            //   });
                            // }
                            // if(newValueSelected=="Access Bank"){
                            //   fetchCustomerBankAndNames("Access Bank");
                            //   setState(() {
                            //     bankSelected = true;
                            //   });
                            // }
                            // if(newValueSelected=="Cal Bank"){
                            //   fetchCustomerBankAndNames("Cal Bank");
                            //   setState(() {
                            //     bankSelected = true;
                            //   });
                            // }
                            // if(newValueSelected=="Fidelity Bank"){
                            //   fetchCustomerBankAndNames("Fidelity Bank");
                            //   setState(() {
                            //     bankSelected = true;
                            //   });
                            // }
                            // if(newValueSelected=="Ecobank"){
                            //   fetchCustomerBankAndNames("Ecobank");
                            //   setState(() {
                            //     bankSelected = true;
                            //   });
                            // }
                            // if(newValueSelected=="Pan Africa"){
                            //   fetchCustomerBankAndNames("Pan Africa");
                            //   setState(() {
                            //     bankSelected = true;
                            //   });
                            // }
                            // if(newValueSelected=="First Bank of Nigeria"){
                            //   fetchCustomerBankAndNames("First Bank of Nigeria");
                            //   setState(() {
                            //     bankSelected = true;
                            //   });
                            // }
                            // if(newValueSelected=="SGSSB"){
                            //   fetchCustomerBankAndNames("SGSSB");
                            //   setState(() {
                            //     bankSelected = true;
                            //   });
                            // }
                            // if(newValueSelected=="Mtn"){
                            //   fetchCustomerBankAndNames("Mtn");
                            //   setState(() {
                            //     bankSelected = true;
                            //   });
                            // }
                            // if(newValueSelected=="Vodafone"){
                            //   fetchCustomerBankAndNames("Vodafone");
                            //   setState(() {
                            //     bankSelected = true;
                            //   });
                            // }
                            // if(newValueSelected=="Tigoairtel"){
                            //   fetchCustomerBankAndNames("Tigoairtel");
                            //   setState(() {
                            //     bankSelected = true;
                            //   });
                            // }

                            _onDropDownItemSelectedBank(newValueSelected);
                          },
                          value: _currentSelectedBank,
                        ),
                      ),
                    ),
                  ): isFetching ? const Text("Please wait fetching customer's banks"):Container(),
                  !isFetching ? Column(
                    children: [
                      accountNumberSelected ? Container() : Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10),
                            child: DropdownButton(
                              hint: const Text("Select account number"),
                              isExpanded: true,
                              underline: const SizedBox(),
                              // style: const TextStyle(
                              //     color: Colors.black, fontSize: 20),
                              items: userAccounts.map((dropDownStringItem) {
                                return DropdownMenuItem(
                                  value: dropDownStringItem,
                                  child: Text(dropDownStringItem),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                for(var cNum in myUser){
                                  if(cNum['account_number'] == newValueSelected){
                                    setState(() {
                                      isAccountNumberAndName = true;
                                      agentAccountName = cNum['account_name'];
                                      agentAccountLinkedNumber = cNum['mtn_linked_number'];
                                      accountNumberSelected = true;
                                    });
                                  }
                                }
                                _onDropDownItemSelectedAccountNumber(newValueSelected);
                              },
                              value: _currentAccountNumberSelected,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ): bankSelected ? Text("Please wait fetching customer's $_currentSelectedBank account numbers"):Container(),

                  isAccountNumberAndName ?
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          readOnly: true,
                          initialValue: _currentAccountNumberSelected.toString(),
                          cursorColor: secondaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(
                              labelText: "Account Number",
                              labelStyle: const TextStyle(color: secondaryColor),
                              focusColor: secondaryColor,
                              fillColor: secondaryColor,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: secondaryColor, width: 2),
                                  borderRadius: BorderRadius.circular(12)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _agentAccountNameController..text=agentAccountName,
                          cursorColor: secondaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          readOnly: true,
                          decoration: InputDecoration(
                              labelText: "Account's name",
                              labelStyle: const TextStyle(color: secondaryColor),
                              focusColor: secondaryColor,
                              fillColor: secondaryColor,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: secondaryColor, width: 2),
                                  borderRadius: BorderRadius.circular(12)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          keyboardType: TextInputType.text,
                          // validator: (value) {
                          //   if (value!.isEmpty) {
                          //     return "Please enter a name";
                          //   }
                          // },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _agentLinkedNumController..text=agentAccountLinkedNumber,
                          cursorColor: secondaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          readOnly: true,
                          decoration: InputDecoration(
                              labelText: "Linked Number",
                              labelStyle: const TextStyle(color: secondaryColor),
                              focusColor: secondaryColor,
                              fillColor: secondaryColor,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: secondaryColor, width: 2),
                                  borderRadius: BorderRadius.circular(12)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          keyboardType: TextInputType.text,
                          // validator: (value) {
                          //   if (value!.isEmpty) {
                          //     return "Please enter a name";
                          //   }
                          // },
                        ),
                      ),
                    ],
                  ):
                  Container(),
                  isAccountNumberAndName ?
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _amountController,
                      cursorColor: secondaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(

                          labelText: "Enter amount",
                          labelStyle: const TextStyle(color: secondaryColor),
                          focusColor: secondaryColor,
                          fillColor: secondaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: secondaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter amount";
                        }
                      },
                    ),
                  ):Container(),
                  RawMaterialButton(
                    onPressed: () {

                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        Get.offAll(() => const Dashboard());
                        switch(_currentSelectedBank){
                          case "Zenith Bank":
                            openOwnerFinancialServicesPullFromBank("1",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "ADB":
                            openOwnerFinancialServicesPullFromBank("2",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "GN Bank":
                            openOwnerFinancialServicesPullFromBank("3",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "GT Bank":
                            openOwnerFinancialServicesPullFromBank("4",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "Fidelity Bank":
                            openOwnerFinancialServicesPullFromBank("5",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "Access Bank":
                            openOwnerFinancialServicesPullFromBank("6",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "CalBank":
                            openOwnerFinancialServicesPullFromBank("7",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "Ecobank":
                            openOwnerFinancialServicesPullFromBank("8",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "UBA":
                            openOwnerFinancialServicesPullFromBank("9",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "Republic":
                            openOwnerFinancialServicesPullFromBank("10",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "CBG":
                            openOwnerFinancialServicesPullFromBank("11",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "First Atlantic":
                            openOwnerFinancialServicesPullFromBank("12",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "Stanbic":
                            openOwnerFinancialServicesPullFromBank("13",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "GCB":
                            openOwnerFinancialServicesPullFromBank("14",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "ABSA":
                            openOwnerFinancialServicesPullFromBank("15",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "UMB":
                            openOwnerFinancialServicesPullFromBank("16",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "FNB":
                            openOwnerFinancialServicesPullFromBank("17",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                          case "Bank Of Africa":
                            openOwnerFinancialServicesPullFromBank("4",agentAccountLinkedNumber,_amountController.text.trim());
                            break;
                        }
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    elevation: 8,
                    fillColor: secondaryColor,
                    splashColor: defaultWhite,
                    child: const Text(
                      "Send",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }


  void _onDropDownItemSelectedBank(newValueSelected) {
    setState(() {
      _currentSelectedBank = newValueSelected;
    });
  }

  void _onDropDownItemSelectedAccountNumber(newValueSelected) {
    setState(() {
      _currentAccountNumberSelected = newValueSelected;
    });
  }
}
