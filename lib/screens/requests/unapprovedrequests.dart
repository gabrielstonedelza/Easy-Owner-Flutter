import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../widget/loadingui.dart';
import 'approverequest.dart';


class AllUnApprovedRequests extends StatefulWidget {
  const AllUnApprovedRequests({Key? key}) : super(key: key);

  @override
  State<AllUnApprovedRequests> createState() => _AllUnApprovedRequestsState();
}

class _AllUnApprovedRequestsState extends State<AllUnApprovedRequests> {

  late String uToken = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allRequests = [];

  Future<void> getAllRequests(String token) async {
    const url = "https://fnetagents.xyz/get_unapproved_requests/";
    var link = Uri.parse(url);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $token"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      allRequests.assignAll(jsonData);
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
    getAllRequests(uToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requests"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading
          ? const LoadingUi()
          : ListView.builder(
          itemCount: allRequests != null ? allRequests.length : 0,
          itemBuilder: (context, index) {
            items = allRequests[index];
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: Card(
                color: secondaryColor,
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // shadowColor: Colors.pink,
                child: Padding(
                  padding:
                  const EdgeInsets.only(top: 18.0, bottom: 18),
                  child: ListTile(
                    onTap: (){
                      Get.to(() => ApproveRequest(id:allRequests[index]['id'].toString(),amount:allRequests[index]['amount'],agent:allRequests[index]['agent'].toString(),owner:allRequests[index]['owner'].toString(), network:allRequests[index]['amount']));
                    },
                    title: buildRow("Amount: ", "amount"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        items["bank"] == "" ? Container():
                        buildRow("Bank: ", "bank"),
                        items["network"] == "" ? Container():
                        buildRow("Network: ", "network"),
                        buildRow("Approved: ", "request_approved"),
                        buildRow("Paid: ", "request_paid"),
                        items["reference"] == "" ? Container():
                        buildRow("Reference: ", "reference"),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0,top: 2),
                          child: Row(
                            children: [
                              const Text("Date : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(items['date_requested'].toString().split("T").first, style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding:  EdgeInsets.only(top:18.0,left: 8),
                          child: Text("Tap to approve request",style: TextStyle(fontWeight: FontWeight.bold,color: snackBackground),),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
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
