import 'package:device_apps/device_apps.dart';
import 'package:easy_owner/constants.dart';
import 'package:easy_owner/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

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
      addToApprovedRequest();
      Get.snackbar("Success", "request was approved",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          backgroundColor: snackBackground);

      Get.offAll(() => const Dashboard());
      showInstalled();
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
  Future<void> openFinancialServices() async {
    await UssdAdvanced.multisessionUssd(code: "*171*6*1*1#", subscriptionId: 1);
  }
  Future<void> openForRequest() async {
    await UssdAdvanced.multisessionUssd(code: "*171#", subscriptionId: 1);
  }

  Future<void> fetchAllInstalled() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true, includeSystemApps: true,includeAppIcons: true);
    // if (kDebugMode) {
    //   print(apps);
    // }
  }
  void showInstalled() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Card(
        elevation: 12,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10))),
        child: SizedBox(
          height: 450,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                  child: Text("Continue with mtn's financial services",
                      style: TextStyle(
                          fontWeight: FontWeight.bold))),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      openForRequest();
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/momo.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Request",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      openFinancialServices();
                      // Get.back();
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/momo.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Push",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      DeviceApps.openApp('com.mtn.agentapp');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/momo.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("App",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      openFinancialServices();
                      // Get.back();
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/momo.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Pull",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              const Center(
                  child: Text("Continue with apps",
                      style: TextStyle(
                          fontWeight: FontWeight.bold))),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('com.ecobank.xpresspoint');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/xpresspoint.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Express Point",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('sg.android.fidelity');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/fidelity-card.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Fidelity Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('calbank.com.ams');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/calbank.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Cal Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              const Divider(),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('accessmob.accessbank.com.accessghana');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/accessbank.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Access Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('com.m2i.gtexpressbyod');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/gtbank.jpg",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("GT Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      DeviceApps.openApp('firstmob.firstbank.com.fbnsubsidiary');
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/full-branch.jpg",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("FBN Bank",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
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
    fetchAllInstalled();
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
