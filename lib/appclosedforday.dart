import 'package:easy_owner/login.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';

class CloseAppForDay extends StatelessWidget {
  const CloseAppForDay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
                child: Text("Sorry app is closed for the day",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
            ),
            const Center(
                child: Text("App will resume at working times or you can login again.",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
            ),
            TextButton(
              onPressed: (){
                Get.offAll(() => const LoginView());
              },
              child: const Text("Login")
            )
          ],
        )
    );
  }
}
