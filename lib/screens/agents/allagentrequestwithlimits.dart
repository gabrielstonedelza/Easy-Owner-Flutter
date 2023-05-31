import 'dart:convert';
import 'package:easy_owner/widget/loadingui.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';




class AllAgentsRequestsLimit extends StatefulWidget {
  const AllAgentsRequestsLimit({Key? key}) : super(key: key);

  @override
  _AllAgentsRequestsLimitState createState() => _AllAgentsRequestsLimitState();
}

class _AllAgentsRequestsLimitState extends State<AllAgentsRequestsLimit> {
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

  fetchAllAgentsRequestLimit()async{
    const url = "https://fnetagents.xyz/get_all_my_agents_request_limits/";
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

    fetchAllAgentsRequestLimit();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: const Text("All My Agents with limits"),
      ),
      body: SafeArea(
          child:
          isLoading ? const LoadingUi() : ListView.builder(
              itemCount: allMyAgents != null ? allMyAgents.length : 0,
              itemBuilder: (context,i){
                items = allMyAgents[i];

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
                                  Text(items['get_agents_username'].toString(),style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                ],
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top:10.0),
                              child: Row(
                                children: [
                                  Text("Limit : ".toString(),style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  Text(items['request_limit'].toString(),style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                ],
                              ),
                            ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: snackBackground,
        onPressed: (){

        },
        child: const Icon(Icons.add,size: 30,),
      ),
    );
  }
}
