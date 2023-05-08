// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../controller/agentcontroller.dart';
//
//
// class MyAgents extends StatefulWidget {
//   const MyAgents({Key? key}) : super(key: key);
//
//   @override
//   State<MyAgents> createState() => _MyAgentsState();
// }
//
// class _MyAgentsState extends State<MyAgents> {
//   final AgentsController agentController = Get.find();
//   var items;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, size: 25, color: Colors.black),
//             onPressed: () {
//               Get.back();
//             },
//           ),
//           title: const Text("Agents",
//               style:
//               TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//         ),
//         body: Stack(
//           children: [
//             ImageFiltered(
//               imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
//               child: Center(
//                 child: OverflowBox(
//                   maxWidth: double.infinity,
//                   child: Transform.translate(
//                     offset: const Offset(200, 100),
//                     child: Image.asset("assets/images/spline.png",
//                         fit: BoxFit.cover),
//                   ),
//                 ),
//               ),
//             ),
//             ImageFiltered(
//                 imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
//                 child: const rv.RiveAnimation.asset("assets/rive/shapes.riv")),
//             GetBuilder<AgentsController>(builder: (controller) {
//               return ListView.builder(
//                 itemCount: controller.allMyAgents != null
//                     ? controller.allMyAgents.length
//                     : 0,
//                 itemBuilder: (context, index) {
//                   items = controller.allMyAgents[index];
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: GlassContainer(
//                       height: 120,
//                       width: MediaQuery.of(context).size.width,
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.white.withOpacity(0.40),
//                           Colors.white.withOpacity(0.10),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderGradient: LinearGradient(
//                         colors: [
//                           Colors.white.withOpacity(0.60),
//                           Colors.white.withOpacity(0.10),
//                           Colors.purpleAccent.withOpacity(0.05),
//                           Colors.purpleAccent.withOpacity(0.60),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         stops: [0.0, 0.39, 0.40, 1.0],
//                       ),
//                       blur: 20,
//                       borderRadius: BorderRadius.circular(24.0),
//                       borderWidth: 1.0,
//                       elevation: 3.0,
//                       isFrostedGlass: true,
//                       shadowColor: Colors.purple.withOpacity(0.20),
//                       child: ListTile(
//                         leading: const Icon(Icons.person),
//                         title: Padding(
//                           padding:  const EdgeInsets.only(top:8.0,bottom:10),
//                           child: Text("${items['username'].toString().capitalize}",style:const TextStyle(fontWeight:FontWeight.bold)),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(items['email']),
//                             const SizedBox(height:10),
//                             Text(items['full_name']),
//                             const SizedBox(height:10),
//                             Text(items['phone_number']),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             })
//           ],
//         ));
//   }
// }
