import 'dart:ui' as ui;

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

import '../../constants/agoraVideoCallAppID.dart';

class CallPage extends StatefulWidget {
  final String channelName;

  const CallPage({Key? key, required this.channelName}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    Wakelock.disable();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    initialize();
  }

  Future<void> initialize() async {
    if (agoraVideoCallAppID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(agoraVideoCallAppID);
    await _engine.enableVideo();
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, reason) {
        setState(() {
          final info = 'userOffline: $uid , reason: $reason';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideoFrame: $uid';
          _infoStrings.add(info);
        });
      },
    ));
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: const Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('مكالمة مع الدكتور'),
              ),
              backgroundColor: Colors.black,
              body: Center(
                child: Stack(
                  children: <Widget>[
                    _viewRows(),
                    _toolbar(),
                  ],
                ),
              ),
            )));
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(const RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(
          uid: uid,
          channelId: widget.channelName,
        )));
    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Column(
          children: <Widget>[_videoView(views[0])],
        );
      case 2:
        return Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        );
      case 3:
        return Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        );
      case 4:
        return Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        );
      default:
    }
    return Container();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => Directionality(
              textDirection: ui.TextDirection.rtl,
              child: AlertDialog(
                title: const Text(
                  'إنهاء المحادثة',
                  style: TextStyle(color: Colors.black),
                  textDirection: ui.TextDirection.rtl,
                ),
                content: const Text('هل متأكد من أنك تريد إنهاء هذه المحادثة ؟',
                    style: const TextStyle(color: Colors.black),
                    textDirection: ui.TextDirection.rtl),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('لا'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'Ok');
                      Navigator.pop(context);
                    },
                    child: const Text('نعم'),
                  ),
                ],
              )),
        )) ??
        false;
  }

  void _onCallEnd(BuildContext bContext) {
    showDialog<String>(
        context: bContext,
        barrierDismissible: false,
        builder: (BuildContext context) => Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              title: const Text(
                'إنهاء المحادثة',
                style: TextStyle(color: Colors.black),
                textDirection: ui.TextDirection.rtl,
              ),
              content: const Text('هل متأكد من أنك تريد إنهاء هذه المحادثة ؟',
                  style: TextStyle(color: Colors.black),
                  textDirection: ui.TextDirection.rtl),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('لا'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'Ok');
                    Navigator.pop(bContext);
                  },
                  child: const Text('نعم'),
                ),
              ],
            )));
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }
}
