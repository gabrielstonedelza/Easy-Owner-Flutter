import 'dart:convert';
import 'package:easy_owner/widget/loadingui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../constants.dart';
import 'controller/profilecontroller.dart';



class AllAgents extends StatefulWidget {
  const AllAgents({Key? key}) : super(key: key);

  @override
  _AllAgentsState createState() => _AllAgentsState();
}

class _AllAgentsState extends State<AllAgents> {
  final ProfileController profileController = Get.find();
  late List allMyAgents = [];
  bool isLoading = true;
  late var items;
  late List customerNumber = [];
  // late String username = "";
  String profileId = "";
  String supId = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List lastMessage = [];

  fetchAllAgents()async{
    final url = "https://fnetagents.xyz/get_supervisor_agents/${profileController.ownersUsername}/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink,headers: {"Authorization": "Token $uToken"});

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMyAgents = json.decode(jsonData);
    }

    setState(() {
      isLoading = false;
      allMyAgents = allMyAgents;
    });
  }

  fetchAllPrivateMessages(String receiverId) async {
    final url = "https://fnetagents.xyz/get_private_message/${profileController.userId}/$receiverId/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      lastMessage = json.decode(jsonData);
      // print(lastMessage.last['message']);
      setState(() {
        isLoading = false;
      });
    }
    else{
      if (kDebugMode) {
        // print(response.body);
      }
    }
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
    }if (storage.read("agent_code") != null) {
      setState(() {
        supId = storage.read("agent_code");
      });
    }
    if (storage.read("profile_id") != null) {
      setState(() {
        hasToken = true;
        profileId = storage.read("profile_id");
      });
    }

    fetchAllAgents();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text("All My Agents"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchAllAgents();
            },
          )
        ],
      ),
      body: SafeArea(
          child:
          isLoading ? const LoadingUi() : ListView.builder(
              itemCount: allMyAgents != null ? allMyAgents.length : 0,
              itemBuilder: (context,i){
                items = allMyAgents[i];
                // fetchAllPrivateMessages(allMyAgents[i]['id'].toString());
                return Column(
                  children: [
                    const SizedBox(height: 10,),
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
                          padding: const EdgeInsets.only(bottom: 1),
                          child: ListTile(
                            onTap: (){
                              // Get.to(()=> PrivateChat();
                              // fetchAllPrivateMessages(allMyAgents[i]['id'].toString());
                            },
                            leading: const CircleAvatar(
                                backgroundColor: primaryColor,
                                // foregroundColor: Colors.white,
                                child: Icon(Icons.person,color: snackBackground,)
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(items['username'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  lastMessage.isNotEmpty ? Text(lastMessage.last['timestamp'].toString().split("T").first,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),):Container(),
                                ],
                              ),
                            ),
                            // subtitle:lastMessage.isNotEmpty ? Padding(
                            //   padding: const EdgeInsets.only(top:10.0),
                            //   child: Text(lastMessage.last['message']),
                            // ) : Container(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5,)
                  ],
                );
              }
          )
      ),

    );
  }
}
