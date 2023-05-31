import 'dart:convert';
import 'package:easy_owner/widget/loadingui.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

class Meetings extends StatefulWidget {
  const Meetings({Key? key}) : super(key: key);

  @override
  State<Meetings> createState() => _MeetingsState();
}

class _MeetingsState extends State<Meetings> {
  final storage = GetStorage();
  late String username = "";
  late String uToken = "";
  var items;
  bool isLoading = true;
  List meetings = [];

  Future<void> _launchInBrowser(String myUrl) async {
    final Uri url = Uri.parse(myUrl);
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> getAllMeetings() async {
    const url = "https://fnetagents.xyz/get_all_meetings/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      meetings = json.decode(jsonData);
      setState(() {
        isLoading = false;
      });
    } else {
      if (kDebugMode) {
        // print(response.body);
      }
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
    getAllMeetings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meetings"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading
          ? const LoadingUi()
          : ListView.builder(
        itemCount: meetings != null ? meetings.length : 0,
        itemBuilder: (context, index) {
          items = meetings[index];
          return Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: ListTile(
                title: Text(items['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: Text(items['message']),
                      ),
                      GestureDetector(
                        onTap: ()async{
                          await _launchInBrowser (items['meeting_link']);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 18.0),
                          child: Row(
                            children: [
                              Text("Meeting Link  ",style:TextStyle(fontWeight: FontWeight.bold,color:Colors.blue)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: Row(
                          children: [
                            const Text("Date : ",style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(items['date_of_meeting']),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: Row(
                          children: [
                            const Text("Time : ",style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(items['time_of_meeting']),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Text("Date Created : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(items['date_created']
                              .toString()
                              .split("T")
                              .first),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
