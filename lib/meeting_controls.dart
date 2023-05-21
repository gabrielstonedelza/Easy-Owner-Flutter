import 'package:flutter/material.dart';

import 'constants.dart';

class MeetingControls extends StatefulWidget {
  final String hlsState;
  final void Function() onToggleMicButtonPressed;
  final void Function() onToggleCameraButtonPressed;
  final void Function() onHLSButtonPressed;

  const MeetingControls(
      {super.key,
        required this.hlsState,
        required this.onToggleMicButtonPressed,
        required this.onToggleCameraButtonPressed,
        required this.onHLSButtonPressed});

  @override
  State<MeetingControls> createState() => _MeetingControlsState();
}

class _MeetingControlsState extends State<MeetingControls> {

  bool isCameraOff = false;

  bool isMicOff = false;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
            ),
            onPressed: (){
              setState(() {
                isMicOff = !isMicOff;
              });
              widget.onToggleMicButtonPressed();
            },
            child: isMicOff ? Image.asset("assets/images/no-microphone.png",width: 30,height: 30,) : Image.asset("assets/images/mic-outline.png",width: 30,height: 30)),
        const SizedBox(width: 10),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
            ),
            onPressed: (){
              setState(() {
                isCameraOff = !isCameraOff;
              });
              widget.onToggleCameraButtonPressed();
            },
            child: isCameraOff ? Image.asset("assets/images/video.png",width: 30,height: 30,) : Image.asset("assets/images/zoom.png",width: 30,height: 30)),
        const SizedBox(width: 10),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
            ),
            onPressed: widget.onHLSButtonPressed,
            child: Text(widget.hlsState == "HLS_STOPPED"
                ? 'Start HLS'
                : widget.hlsState == "HLS_STARTING"
                ? "Starting HLS"
                : widget.hlsState == "HLS_STARTED" || widget.hlsState == "HLS_PLAYABLE"
                ? "Stop HLS"
                : widget.hlsState == "HLS_STOPPING"
                ? "Stopping HLS"
                : "Start HLS")),
      ],
    );
  }
}