import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../controller/customercontroller.dart';
import '../dashboard.dart';
import '../widget/loadingui.dart';
import 'addfloat.dart';


class Floats extends StatefulWidget {
  const Floats({Key? key}) : super(key: key);

  @override
  State<Floats> createState() => _FloatsState();
}

class _FloatsState extends State<Floats> {
  final CustomersController controller = Get.find();
  late String uToken = "";
  late String agentCode = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List myFloatStatus = [];
  late List allMyFloats = [];
  bool isApproved = false;
  bool isRegisteredForFloat = false;
  late List agentsRegisteredForFloat = [];
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

  // Future<void> getMyFloatStatus(String token) async {
  //   try {
  //     const url = "https://fnetagents.xyz/get_all_my_floats/";
  //     var link = Uri.parse(url);
  //     http.Response response = await http.get(link, headers: {
  //       "Content-Type": "application/x-www-form-urlencoded",
  //       "Authorization": "Token $token"
  //     });
  //     if (response.statusCode == 200) {
  //       var jsonData = jsonDecode(response.body);
  //       myFloatStatus.assignAll(jsonData);
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     Get.snackbar("Sorry",
  //         "something happened or please check your internet connection");
  //   } finally {
  //
  //   }
  // }

  Future<void> getAllMyFloats(String token) async {
    try {
      const url = "https://fnetagents.xyz/get_all_my_floats/";
      var link = Uri.parse(url);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        allMyFloats.assignAll(jsonData);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      Get.snackbar("Sorry",
          "something happened or please check your internet connection");
    }
  }

  // requestToJoinFloat()async{
  //   const registerUrl = "https://fnetagents.xyz/request_to_join_float/";
  //   final myLink = Uri.parse(registerUrl);
  //   final res = await http.post(myLink, headers: {
  //     "Content-Type": "application/x-www-form-urlencoded",
  //     "Authorization": "Token $uToken"
  //   }, body: {
  //
  //   });
  //   if(res.statusCode == 201){
  //     Get.snackbar("Congratulations", "float request sent",
  //         colorText: defaultWhite,
  //         snackPosition: SnackPosition.TOP,
  //         duration: const Duration(seconds: 5),
  //         backgroundColor: snackBackground);
  //     Get.offAll(()=>const Dashboard());
  //   }
  //   else{
  //     Get.snackbar("Error", "Something went wrong",
  //         colorText: defaultWhite,
  //         snackPosition: SnackPosition.TOP,
  //         backgroundColor: Colors.red);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    if (storage.read("agent_code") != null) {
      setState(() {
        agentCode = storage.read("agent_code");
      });
    }
    // getMyFloatStatus(uToken);
    getAllMyFloats(uToken);

    // for(var i in agentsRegisteredForFloat){
    //   if(i == agentCode){
    //     setState(() {
    //       isRegisteredForFloat = true;
    //     });
    //   }
    //   else{
    //     isRegisteredForFloat = false;
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Floats"),
      ),
      body: isLoading ? const LoadingUi() :
      ListView.builder(
          itemCount: allMyFloats != null ? allMyFloats.length : 0,
          itemBuilder: (context, index) {
            items = allMyFloats[index];
            return Card(
              color: secondaryColor,
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: buildRow("Request: ", "float_request"),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 2),
                  child: Row(
                    children: [
                      const Text(
                        "Date: ",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        items['date_requested']
                            .toString()
                            .split("T")
                            .first,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        onPressed: (){
          Get.to(() => const AddFloat());
        },
        child: const Icon(Icons.add,size: 30,color: defaultWhite,),
      )
    );
  }

  Padding buildRow(String mainTitle, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            mainTitle,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            items[subtitle],
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
