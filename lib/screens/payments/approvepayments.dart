import 'package:easy_owner/constants.dart';
import 'package:easy_owner/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';

import '../../widget/loadingui.dart';

class ApprovePayments extends StatefulWidget {
  final id;
  final amount;
  final agent;
  final owner;
  final reference;
  const ApprovePayments({Key? key,required this.id,required this.amount,required this.agent,required this.owner,required this.reference}) : super(key: key);

  @override
  State<ApprovePayments> createState() => _ApprovePaymentsState(id:this.id,amount:this.amount,agent:this.agent,owner:this.owner,reference:this.reference);
}

class _ApprovePaymentsState extends State<ApprovePayments> {
  final id;
  final amount;
  final agent;
  final owner;
  final reference;
  _ApprovePaymentsState({required this.id,required this.amount,required this.agent,required this.owner,required this.reference});
  late String uToken = "";
  late List allRequests = [];
  final storage = GetStorage();
  bool isPosting = false;
  bool isReference = false;
  late final TextEditingController _referenceController;
  FocusNode referenceFocusNode = FocusNode();

  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  approvePayment() async {
    final requestUrl = "https://fnetagents.xyz/update_agent_payment_request/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
      "payment_approved": "Approved",
      "amount": amount,
      "agent": agent,
      "owner": owner,
    });
    if (response.statusCode == 200) {
      addToApprovedPayment();
      Get.snackbar("Success", "payment was approved",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: snackBackground);

      Get.offAll(() => const Dashboard());
    } else {
// print(response.body);
      Get.snackbar("Approve Error", "something happened. Please try again",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
    }
  }

  addToApprovedPayment()async{
    const addToApproveUrl = "https://fnetagents.xyz/add_to_approve_request_payment/";
    final myLink = Uri.parse(addToApproveUrl);
    final response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    },body: {
      "payment": id,
    });
    if(response.statusCode == 201){

    }else{
      // print(response.body);
    }
  }

  deletePayment() async {
    final url = "https://fnetagents.xyz/delete_agent_payment_request/$id";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 204) {
      Get.offAll(() => const Dashboard());
    } else {

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
    _referenceController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Approve Payment"),
        backgroundColor: secondaryColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          !isReference ? Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Center(
              child: Text("Reference is $reference",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
            ),
          ) : Container(),
         !isReference ? Padding(
            padding:
            const EdgeInsets.only(bottom: 18.0,left: 18,right: 18),
            child: TextFormField(
              onChanged: (value){
                if(value == reference){
                  setState(() {
                    isReference = true;
                  });
                }
                else{
                  setState(() {
                    isReference = false;
                  });
                }
              },
              controller: _referenceController,
              focusNode: referenceFocusNode,
              cursorRadius:
              const Radius.elliptical(10, 10),
              cursorWidth: 10,
              cursorColor: secondaryColor,
              decoration: buildInputDecoration(
                  "Enter Reference"),
              keyboardType: TextInputType.text,
            ),
          ) : Container(),
          isReference ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom:18.0),
                child: Center(
                  child: Text("Approve payment of GHC$amount",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                ),
              ),
              isPosting  ? const LoadingUi() :  Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: NeoPopTiltedButton(
                        isFloating: true,
                        onTapUp: () {
                          _startPosting();
                          approvePayment();
                        },
                        decoration: const NeoPopTiltedButtonDecoration(
                          color: secondaryColor,
                          plunkColor: secondaryColor,
                          shadowColor: Color.fromRGBO(36, 36, 36, 1),
                          showShimmer: true,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical: 10,
                          ),
                          child: Text('Approve',style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: NeoPopTiltedButton(
                        isFloating: true,
                        onTapUp: () {
                          _startPosting();
                          deletePayment();
                        },
                        decoration: const NeoPopTiltedButtonDecoration(
                          color: warning,
                          plunkColor: warning,
                          shadowColor: Color.fromRGBO(36, 36, 36, 1),
                          showShimmer: true,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical: 10,
                          ),
                          child: Text('Delete',style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ) : Container(),
        ],
      ),
    );
  }

  InputDecoration buildInputDecoration(String text) {
    return InputDecoration(
      labelStyle: const TextStyle(color: secondaryColor),
      labelText: text,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: secondaryColor, width: 2),
          borderRadius: BorderRadius.circular(12)),
    );
  }
}
