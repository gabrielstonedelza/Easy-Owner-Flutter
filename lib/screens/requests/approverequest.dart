import 'package:easy_owner/constants.dart';
import 'package:easy_owner/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';

import '../../widget/loadingui.dart';

class ApproveRequest extends StatefulWidget {
  final id;
  final amount;
  final agent;
  final owner;
  const ApproveRequest({Key? key,required this.id,required this.amount,required this.agent,required this.owner}) : super(key: key);

  @override
  State<ApproveRequest> createState() => _ApproveRequestState(id:this.id,amount:this.amount,agent:this.agent,owner:this.owner);
}

class _ApproveRequestState extends State<ApproveRequest> {
  final id;
  final amount;
  final agent;
  final owner;
  _ApproveRequestState({required this.id,required this.amount,required this.agent,required this.owner});
  late String uToken = "";
  late List allRequests = [];
  final storage = GetStorage();
  bool isPosting = false;

  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }

  approveRequest() async {
    final requestUrl = "https://fnetagents.xyz/update_agent_request/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
      "request_approved": "Approved",
      "amount": amount,
      "agent": agent,
      "owner": owner,
    });
    if (response.statusCode == 200) {
      addToApprovedRequest()();
      Get.snackbar("Success", "request was approved",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: snackBackground);

      Get.offAll(() => const Dashboard());
    } else {

      Get.snackbar("Approve Error", "something happened. Please try again",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: warning);
    }
  }
  addToApprovedRequest()async{
    const addToApproveUrl = "https://fnetagents.xyz/add_to_approve_request/";
    final myLink = Uri.parse(addToApproveUrl);
    final response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    },body: {
      "agent_request": id,
    });
    if(response.statusCode == 201){

    }else{
      // print(response.body);
    }
  }

  deleteRequest() async {
    final url = "https://fnetagents.xyz/delete_agent_request/$id";
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Approve Request"),
        backgroundColor: secondaryColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom:18.0),
            child: Center(
              child: Text("Approve request of GHC$amount",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
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
                      approveRequest();
                    },
                    decoration: const NeoPopTiltedButtonDecoration(
                      color: secondaryColor,
                      plunkColor: Color.fromRGBO(255, 235, 52, 1),
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
                      deleteRequest();
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
      ),
    );
  }
}
