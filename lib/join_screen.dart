import 'package:flutter/material.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'api_call.dart';
import 'constants.dart';
import 'ils_screen.dart';
import 'package:videosdk/videosdk.dart';

class JoinScreen extends StatelessWidget {
  final _meetingIdController = TextEditingController();

  JoinScreen({super.key});
  FocusNode meetingFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  //Creates new Meeting Id and joins it in CONFERNCE mode.
  void onCreateButtonPressed(BuildContext context) async {
    // call api to create meeting and navigate to ILSScreen with meetingId,token and mode
    await createMeeting().then((meetingId) {
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ILSScreen(
            meetingId: meetingId,
            token: token,
            mode: Mode.CONFERENCE,
          ),
        ),
      );
    });
  }

  //Join the provided meeting with given Mode and meetingId
  void onJoinButtonPressed(BuildContext context, Mode mode) {
    // check meeting id is not null or invaild
    // if meeting id is vaild then navigate to ILSScreen with meetingId, token and mode
    String meetingId = _meetingIdController.text;
    var re = RegExp("\\w{4}\\-\\w{4}\\-\\w{4}");
    if (meetingId.isNotEmpty && re.hasMatch(meetingId)) {
      _meetingIdController.clear();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ILSScreen(
            meetingId: meetingId,
            token: token,
            mode: mode,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter valid meeting id"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Meeting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextFormField(
                  controller: _meetingIdController,
                  focusNode: meetingFocusNode,
                  cursorRadius: const Radius.elliptical(10, 10),
                  cursorWidth: 10,
                  cursorColor: secondaryColor,
                  decoration: buildInputDecoration("Enter Meeting Id"),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter meeting id";
                    }
                    return null;
                  },
                ),
              ),
              NeoPopTiltedButton(
                isFloating: true,
                onTapUp: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  if (!_formKey.currentState!.validate()) {
                    return;
                  } else {
                    onJoinButtonPressed(context, Mode.CONFERENCE);
                  }
                },
                decoration: const NeoPopTiltedButtonDecoration(
                  color: secondaryColor,
                  plunkColor: Color.fromRGBO(255, 235, 52, 1),
                  shadowColor: Color.fromRGBO(36, 36, 36, 1),
                  showShimmer: true,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 70.0,
                    vertical: 15,
                  ),
                  child: Text('Join',style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  InputDecoration buildInputDecoration(String text) {
    return InputDecoration(
      labelStyle: const TextStyle(color: secondaryColor),
      labelText: text,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: secondaryColor, width: 2),
          borderRadius: BorderRadius.circular(12)),
    );
  }
}