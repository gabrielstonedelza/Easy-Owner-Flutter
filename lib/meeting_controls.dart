import 'package:flutter/material.dart';

import 'constants.dart';

class MeetingControls extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
            ),
            onPressed: onToggleMicButtonPressed,
            child: const Text('Toggle Mic')),
        const SizedBox(width: 10),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
            ),
            onPressed: onToggleCameraButtonPressed,
            child: const Text('Toggle WebCam')),
        const SizedBox(width: 10),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
            ),
            onPressed: onHLSButtonPressed,
            child: Text(hlsState == "HLS_STOPPED"
                ? 'Start HLS'
                : hlsState == "HLS_STARTING"
                ? "Starting HLS"
                : hlsState == "HLS_STARTED" || hlsState == "HLS_PLAYABLE"
                ? "Stop HLS"
                : hlsState == "HLS_STOPPING"
                ? "Stopping HLS"
                : "Start HLS")),
      ],
    );
  }
}