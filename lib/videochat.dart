import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zoom_flutter_hello_world/config.dart';
import 'package:zoom_flutter_hello_world/utils/jwt.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_event_listener.dart';
import 'package:flutter_zoom_videosdk/flutter_zoom_view.dart' as zoom_view;

class Videochat extends StatefulWidget {
  const Videochat({super.key});
  @override
  State<Videochat> createState() => _VideochatState();
}

class _VideochatState extends State<Videochat> {
  final zoom = ZoomVideoSdk();
  final eventListener = ZoomVideoSdkEventListener();
  bool isInSession = false;
  List<StreamSubscription> subscriptions = [];
  List<ZoomVideoSdkUser> users = [];
  bool isMuted = true;
  bool isVideoOn = false;
  bool isLoading = false;

  _handleSessionJoin(data) async {
    if (!mounted) return;
    final mySelf = ZoomVideoSdkUser.fromJson(jsonDecode(data['sessionUser']));
    final remoteUsers = await zoom.session.getRemoteUsers() ?? [];
    final isMutedState = await mySelf.audioStatus?.isMuted() ?? true;
    final isVideoOnState = await mySelf.videoStatus?.isOn() ?? false;
    setState(() {
      isInSession = true;
      isLoading = false;
      isMuted = isMutedState;
      isVideoOn = isVideoOnState;
      users = [mySelf, ...remoteUsers];
    });
  }

  _updateUserList(data) async {
    final mySelf = await zoom.session.getMySelf();
    if (mySelf == null) return;
    final remoteUserList = await zoom.session.getRemoteUsers() ?? [];
    remoteUserList.insert(0, mySelf);
    setState(() {
      users = remoteUserList;
    });
  }

  _handleVideoChange(data) async {
    if (!mounted) return;
    final mySelf = await zoom.session.getMySelf();
    final videoStatus = await mySelf?.videoStatus?.isOn() ?? false;
    setState(() {
      isVideoOn = videoStatus;
    });
  }

  _handleAudioChange(data) async {
    if (!mounted) return;
    final mySelf = await zoom.session.getMySelf();
    final audioStatus = await mySelf?.audioStatus?.isMuted() ?? true;
    setState(() {
      isMuted = audioStatus;
    });
  }

  _setupEventListeners() {
    subscriptions = [
      eventListener.addListener(EventType.onSessionJoin, _handleSessionJoin),
      eventListener.addListener(EventType.onSessionLeave, handleLeaveSession),
      eventListener.addListener(EventType.onUserJoin, _updateUserList),
      eventListener.addListener(EventType.onUserLeave, _updateUserList),
      eventListener.addListener(EventType.onUserVideoStatusChanged, _handleVideoChange),
      eventListener.addListener(EventType.onUserAudioStatusChanged, _handleAudioChange),
    ];
  }

  Future startSession() async {
    setState(() => isLoading = true);
    try {
      final token = generateJwt(sessionDetails['sessionName'], sessionDetails['roleType']);
      _setupEventListeners();
      await zoom.joinSession(JoinSessionConfig(
        sessionName: sessionDetails['sessionName']!,
        sessionPassword: sessionDetails['sessionPassword']!,
        token: token,
        userName: sessionDetails['displayName']!,
        audioOptions: {"connect": true, "mute": true},
        videoOptions: {"localVideoOn": true},
        sessionIdleTimeoutMins: int.parse(sessionDetails['sessionTimeout']!),
      ));
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  handleLeaveSession([data]) {
    setState(() {
      isInSession = false;
      isLoading = false;
      users = [];
    });
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Stack(
          children: [
            if (!isInSession)
              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : startSession,
                  child: Text(isLoading ? 'Connecting...' : 'Start Session'),
                ),
              )
            else
              Stack(
                children: [
                  VideoGrid(users: users),
                  ControlBar(
                    isMuted: isMuted,
                    isVideoOn: isVideoOn,
                    onLeaveSession: handleLeaveSession,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class VideoGrid extends StatelessWidget {
  final List<ZoomVideoSdkUser> users;
  const VideoGrid({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: users.length <= 2 ? 1 : 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) => _VideoTile(user: users[index]),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final ZoomVideoSdkUser user;
  const _VideoTile({required this.user});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SizedBox.expand(
        child: zoom_view.View(
          key: Key(user.userId),
          creationParams: {
            "userId": user.userId,
            "videoAspect": VideoAspect.FullFilled,
            "fullScreen": false,
          },
        ),
      ),
    );
  }
}

class ControlBar extends StatelessWidget {
  final bool isMuted;
  final bool isVideoOn;
  final double circleButtonSize = 40.0;
  final zoom = ZoomVideoSdk();
  final VoidCallback onLeaveSession;

  ControlBar({
    super.key,
    required this.isMuted,
    required this.isVideoOn,
    required this.onLeaveSession,
  });

  Future toggleAudio() async {
    final mySelf = await zoom.session.getMySelf();
    if (mySelf?.audioStatus == null) return;
    final isMuted = await mySelf!.audioStatus!.isMuted();
    isMuted ? await zoom.audioHelper.unMuteAudio(mySelf.userId) : await zoom.audioHelper.muteAudio(mySelf.userId);
  }

  Future toggleVideo() async {
    final mySelf = await zoom.session.getMySelf();
    if (mySelf?.videoStatus == null) return;
    final isOn = await mySelf!.videoStatus!.isOn();
    isOn ? await zoom.videoHelper.stopVideo() : await zoom.videoHelper.startVideo();
  }

  Future leaveSession() async {
    await zoom.leaveSession(false);
    onLeaveSession();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: toggleAudio,
              icon: Icon(
                isMuted ? Icons.mic_off : Icons.mic,
              ),
              iconSize: circleButtonSize,
              tooltip: isMuted ? "Unmute" : "Mute",
              color: Colors.white,
            ),
            IconButton(
              onPressed: toggleVideo,
              iconSize: circleButtonSize,
              icon: Icon(
                isVideoOn ? Icons.videocam : Icons.videocam_off,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: leaveSession,
              iconSize: circleButtonSize,
              icon: const Icon(Icons.call_end, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
