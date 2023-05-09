import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../widget/loadingui.dart';


class AgentCustomers extends StatefulWidget {
  final username;
  const AgentCustomers({Key? key,required this.username}) : super(key: key);

  @override
  State<AgentCustomers> createState() => _AgentCustomersState(username:this.username);
}

class _AgentCustomersState extends State<AgentCustomers> {
  final username;
  _AgentCustomersState({required this.username});

  late String uToken = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allMyCustomers = [];

  Future<void> getAllAgentCustomers() async {
    final url = "https://fnetagents.xyz/get_agents_customers/$username";
    var link = Uri.parse(url);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      allMyCustomers.assignAll(jsonData);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    getAllAgentCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("$username's Customers"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading
          ? const LoadingUi()
          : ListView.builder(
          itemCount: allMyCustomers != null ? allMyCustomers.length : 0,
          itemBuilder: (context, index) {
            items = allMyCustomers[index];
            return Card(
              color: secondaryColor,
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: buildRow("Name: ", "name"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow("Phone : ", "phone"),
                    Padding(
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
                            items['date_created']
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
                  ],
                ),
              ),
            );
          }),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: snackBackground,
      //   onPressed: (){
      //     Get.to(() => const SearchCustomers());
      //   },
      //   child: const Icon(Icons.search_rounded,size: 30,color: defaultWhite,),
      // ),
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
