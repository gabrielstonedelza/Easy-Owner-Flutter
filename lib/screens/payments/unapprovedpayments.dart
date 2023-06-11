import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../widget/loadingui.dart';
import 'approvepayments.dart';


class AllUnApprovedPayments extends StatefulWidget {
  const AllUnApprovedPayments({Key? key}) : super(key: key);

  @override
  State<AllUnApprovedPayments> createState() => _AllUnApprovedPaymentsState();
}

class _AllUnApprovedPaymentsState extends State<AllUnApprovedPayments> {

  late String uToken = "";
  final storage = GetStorage();
  var items;
  bool isLoading = true;
  late List allPayments = [];

  Future<void> getAllRequests(String token) async {
    const url = "https://fnetagents.xyz/get_unapproved_payment_requests/";
    var link = Uri.parse(url);
    http.Response response = await http.get(link, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $token"
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      allPayments.assignAll(jsonData);
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
        title: const Text("Payments"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading
          ? const LoadingUi()
          : ListView.builder(
          itemCount: allPayments != null ? allPayments.length : 0,
          itemBuilder: (context, index) {
            items = allPayments[index];
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
                      Get.to(() => ApprovePayments(id:allPayments[index]['id'].toString(),amount:allPayments[index]['amount'],agent:allPayments[index]['agent'].toString(),owner:allPayments[index]['owner'].toString(),reference:allPayments[index]['reference']));
                    },
                    title: buildRow("Amount: ", "amount"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildRow("Payment Approved: ", "payment_approved"),
                        items["reference"] == "" ? Container():
                        // buildRow("Reference: ", "reference"),
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
                          child: Text("Tap to approve payment",style: TextStyle(fontWeight: FontWeight.bold,color: snackBackground),),
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
