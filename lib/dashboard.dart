import 'dart:async';
import 'dart:convert';

import 'package:device_apps/device_apps.dart';
import 'package:easy_owner/screens/aboutpage.dart';
import 'package:easy_owner/screens/agents/addnewagent.dart';
import 'package:easy_owner/screens/agents/myagents.dart';
import 'package:easy_owner/screens/agents/myagentsaccounts.dart';
import 'package:easy_owner/screens/chats/agentsGroupchat.dart';
import 'package:easy_owner/screens/chats/owersgroupchat.dart';
import 'package:easy_owner/screens/chats/privatechat.dart';
import 'package:easy_owner/screens/ownerpayto/paytosummary.dart';
import 'package:easy_owner/screens/payments/unapprovedpayments.dart';
import 'package:easy_owner/screens/rebalancing/unapprovedrebalancing.dart';
import 'package:easy_owner/screens/reportstoday.dart';
import 'package:easy_owner/screens/requests/unapprovedrequests.dart';
import 'package:easy_owner/widget/loadingui.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

import 'authenticatebyphone.dart';

import 'constants.dart';
import 'controller/authphonecontroller.dart';
import 'controller/localnotificationmanager.dart';
import 'controller/notificationcontroller.dart';
import 'controller/profilecontroller.dart';
import 'controller/trialmonthlypayment.dart';
import 'getonlineimage.dart';
import 'join_screen.dart';
import 'login.dart';

import 'meetings.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  NotificationController notificationsController = Get.find();
  final ProfileController profileController = Get.find();
  final storage = GetStorage();
  late String uToken = "";
  late String agentCode = "";
  late Timer _timer;
  bool isLoading = true;

  final _advancedDrawerController = AdvancedDrawerController();
  SmsQuery query = SmsQuery();
  late List mySmss = [];
  int lastSmsCount = 0;
  late List allNotifications = [];

  late List yourNotifications = [];
  Future<void> openFinancialServices() async {
    await UssdAdvanced.multisessionUssd(code: "*171*6*1*1#", subscriptionId: 1);
  }

  late List notRead = [];

  late List triggered = [];

  late List unreadNotifications = [];

  late List triggeredNotifications = [];

  late List notifications = [];

  late List allNots = [];
  bool phoneNotAuthenticated = false;
  final AuthPhoneController authController = Get.find();
  final TrialAndMonthlyPaymentController tpController = Get.find();

  bool isAuthenticated = false;
  bool isAuthenticatedAlready = false;


  Future<void> getAllTriggeredNotifications() async {
    const url = "https://fnetagents.xyz/get_triggered_notifications/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      triggeredNotifications = json.decode(jsonData);
      triggered.assignAll(triggeredNotifications);
    }
  }

  Future<void> getAllUnReadNotifications() async {
    const url = "https://fnetagents.xyz/get_my_unread_notifications/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      yourNotifications = json.decode(jsonData);
      notRead.assignAll(yourNotifications);
    }
  }

  Future<void> getAllNotifications() async {
    const url = "https://fnetagents.xyz/get_my_notifications/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allNotifications = json.decode(jsonData);
      allNots.assignAll(allNotifications);
    }
  }

  unTriggerNotifications(int id) async {
    final requestUrl = "https://fnetagents.xyz/un_trigger_notification/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
      "notification_trigger": "Not Triggered",
      "read": "Read",
    });
    if (response.statusCode == 200) {}
  }

  updateReadNotification(int id) async {
    const requestUrl = "https://fnetagents.xyz/read_notification/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
    });
    if (response.statusCode == 200) {}
  }

  List profileDetails = [];
  late String userId = "";
  late String ownersCode = "";
  bool accountApproved = false;

  Future<void> getUserDetails() async {
    const profileLink = "https://fnetagents.xyz/get_user_details/";
    var link = Uri.parse(profileLink);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      profileDetails = jsonData;
      for(var i in profileDetails){
        userId = i['id'].toString();
        ownersCode = i['agent_unique_code'];
        accountApproved = i['user_approved'];
      }
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> fetchAllInstalled() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true, includeSystemApps: true,includeAppIcons: true);
    // if (kDebugMode) {
    //   print(apps);
    // }
  }
  Future<void> openFinancialServicesPullFromBank() async {
    await UssdAdvanced.multisessionUssd(code: "*171*6*1*2#", subscriptionId: 1);
  }
  Future<void> openForRequest() async {
    await UssdAdvanced.multisessionUssd(code: "*171#", subscriptionId: 1);
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
                      openFinancialServicesPullFromBank();
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
  void dialPayTo(){
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
                  child: Text("Pay to",
                      style: TextStyle(
                          fontWeight:
                          FontWeight.bold))),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Future<void> dialPayToAgent(
                          String agentNumber, String amount, String reference) async {
                        UssdAdvanced.multisessionUssd(
                            code: "*171*1*1*$agentNumber*$agentNumber*$amount*$reference#",
                            subscriptionId: 1);
                      }
                      // Get.back();
                    },
                    child: Column(
                      children: [
                        myOnlineImage("https://cdn-icons-png.flaticon.com/128/2534/2534183.png",70,70),
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
                      Future<void> dialPayToMerchant(String merchantId,String amount,String reference) async {
                        UssdAdvanced.multisessionUssd(code: "*171*1*2*$merchantId*$amount*$reference#",subscriptionId: 1);
                      }
                    },
                    child: Column(
                      children: [
                        myOnlineImage("https://cdn-icons-png.flaticon.com/128/10701/10701763.png",70,70),
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
  }


  @override
  void initState() {
    super.initState();
    fetchAllInstalled();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    if (storage.read("phoneAuthenticated") != null) {
      setState(() {
        phoneNotAuthenticated = true;
      });
    }
    if (storage.read("agent_code") != null) {
      setState(() {
        agentCode = storage.read("agent_code");
      });
    }

    tpController.fetchFreeTrial(uToken);
    tpController.fetchAccountBalance(uToken);
    tpController.fetchMonthlyPayment(uToken);

    notificationsController.getAllNotifications(uToken);
    notificationsController.getAllUnReadNotifications(uToken);
    profileController.getUserDetails(uToken);
    profileController.getUserProfile(uToken);
    getAllTriggeredNotifications();
    getUserDetails();


    _timer = Timer.periodic(const Duration(seconds: 12), (timer) {
      getAllTriggeredNotifications();
      getAllUnReadNotifications();
      for (var i in triggered) {
        NotificationService().showNotifications(title:i['notification_title'], body:i['notification_message']);
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      tpController.fetchFreeTrial(uToken);
      tpController.fetchAccountBalance(uToken);
      tpController.fetchMonthlyPayment(uToken);
      getUserDetails();
      for (var e in triggered) {
        unTriggerNotifications(e["id"]);
      }
    });

  }

  logoutUser() async {
    storage.remove("token");
    storage.remove("agent_code");
    storage.remove("phoneAuthenticated");
    storage.remove("IsAuthDevice");
    Get.offAll(() => const LoginView());
    const logoutUrl = "https://www.fnetagents.xyz/auth/token/logout";
    final myLink = Uri.parse(logoutUrl);
    http.Response response = await http.post(myLink, headers: {
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    });

    if (response.statusCode == 200) {
      Get.snackbar("Success", "You were logged out",
          colorText: defaultWhite,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackBackground);
      storage.remove("token");
      storage.remove("agent_code");
      Get.offAll(() => const LoginView());
    }
  }

  @override
  void dispose(){
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return  isLoading  ? const Scaffold(body: LoadingUi(),) : phoneNotAuthenticated ?  AdvancedDrawer(
        backdropColor: secondaryColor,
        controller: _advancedDrawerController,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        animateChildDecoration: true,
        rtlOpening: false,
        // openScale: 1.0,
        disabledGestures: false,
        childDecoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        drawer: SafeArea(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 140.0,
                  height: 140.0,
                  margin: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 64.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/forapp.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                const Center(
                  child: Text(
                    "Version: 1.1.1",
                    style: TextStyle(
                        fontSize: 20,
                        color: defaultWhite,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(
                  color: secondaryColor,
                ),
                ListTile(
                  onTap: () {
                    Get.to(() => const AboutPage());
                  },
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                ),
                ListTile(
                  onTap: () {
                    Get.defaultDialog(
                        buttonColor: primaryColor,
                        title: "Confirm Logout",
                        middleText: "Are you sure you want to logout?",
                        confirm: RawMaterialButton(
                            shape: const StadiumBorder(),
                            fillColor: secondaryColor,
                            onPressed: () {
                              logoutUser();
                              Get.back();
                            },
                            child: const Text(
                              "Yes",
                              style: TextStyle(color: Colors.white),
                            )),
                        cancel: RawMaterialButton(
                            shape: const StadiumBorder(),
                            fillColor: secondaryColor,
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            )));
                  },
                  leading: const Icon(Icons.logout_sharp),
                  title: const Text('Logout'),
                ),
                const Spacer(),
                Container(
                  width: 140.0,
                  height: 140.0,
                  margin: const EdgeInsets.only(
                    top: 10.0,
                    bottom: 14.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/png.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                const DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom:8.0),
                    child: Text(
                        'App created by Havens Software Development'),
                  ),
                ),
              ],
            ),
          ),
        ),
        child:  Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: _handleMenuButtonPressed,
              icon: ValueListenableBuilder<AdvancedDrawerValue>(
                valueListenable: _advancedDrawerController,
                builder: (_, value, __) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      value.visible ? Icons.clear : Icons.menu,
                      key: ValueKey<bool>(value.visible),
                    ),
                  );
                },
              ),
            ),
            title: Text(ownersCode,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: secondaryColor,
          ),
          body: accountApproved ? ListView(
            children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          myOnlineImage("assets/images/employee.png",70,70),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Register Agent"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const AddNewAgent());
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                        myOnlineImage("assets/images/group.png",70,70),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("My Agents"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const MyAgents());
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          myOnlineImage("assets/images/business-report.png",70,70),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Reports"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const ReportsToday());
                      },
                    ),
                  ),

                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          myOnlineImage("assets/images/ewallet.png",70,70),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Requests"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const AllUnApprovedRequests());
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          myOnlineImage("assets/images/payment-method.png",70,70),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Payments"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const AllUnApprovedPayments());
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          myOnlineImage("assets/images/balance.png",70,70),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("ReBalancing"),
                          const Text("Requests"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const AllUnApprovedReBalancing());

                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          myOnlineImage("assets/images/cash-on-delivery.png",70,70),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Pay To"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const OwnerPayToSummary());
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          myOnlineImage("assets/images/bank.png",70,70),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Financial"),
                          const Text("Services"),
                        ],
                      ),
                      onTap: () {
                        showInstalled();
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          myOnlineImage("assets/images/wallet.png",70,70),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Agent Accounts"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const MyAgentsAccounts());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          myOnlineImage("assets/images/conversation.png",70,70),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Chat"),
                        ],
                      ),
                      onTap: () {
                        showMaterialModalBottomSheet(
                          context: context,
                          builder: (context) => SizedBox(
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.only(top:25.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      child: Column(
                                        children: [
                                          myOnlineImage("assets/images/manager.png",70,70),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Text("Admin"),
                                        ],
                                      ),
                                      onTap: () {
                                        Get.to(()=>const PrivateChat());
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      child: Column(
                                        children: [
                                          myOnlineImage("assets/images/cashier.png",70,70),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Text("Owners"),
                                        ],
                                      ),
                                      onTap: () {
                                        Get.to(()=> const OwnersGroupChat());
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      child: Column(
                                        children: [
                                          myOnlineImage("assets/images/group.png",70,70),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Text("Agent Chat"),
                                        ],
                                      ),
                                      onTap: () {
                                        Get.to(() => const AgentsGroupChat());
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          myOnlineImage("assets/images/meeting.png",70,70),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Meetings"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => const Meetings());
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        children: [
                          myOnlineImage("assets/images/live-streaming.png",70,70),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Live Meeting"),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => JoinScreen());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              const SizedBox(
                height: 20,
              ),
            ],
          ) : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset("assets/images/136192-rejected.json"),
              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Center(
                  child: Text("Sorry,the administrator hasn't approved your account yet,please kindly wait.",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                ),
              ),
              const Center(
                child: Text("Thank you.",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
              ),
            ],
          ),

        )
    ) : Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset("assets/images/96238-auth-failed.json"),
          const Center(
            child: Text(
              "Authentication Error",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: warning,
                  fontSize: 20),
            ),
          ),
          const SizedBox(height: 50,),
          TextButton(
            onPressed: () {
              Get.offAll(() => const AuthenticateByPhone());
            },
            child: const Text("Authenticate",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
          )
        ],
      ),
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
}