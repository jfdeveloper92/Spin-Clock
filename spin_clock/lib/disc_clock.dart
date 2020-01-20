// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:io';
import 'package:digital_clock/constants.dart';
import 'package:digital_clock/spin_disc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'disc_text_painter.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Colors.grey[100],
  _Element.text: Colors.black
};

final _darkTheme = {
  _Element.background: Colors.black38,
  _Element.text: Colors.white
};

class DiscClock extends StatefulWidget {
  const DiscClock(this.model);

  final ClockModel model;

  @override
  _DiscClockState createState() => _DiscClockState();
}

class _DiscClockState extends State<DiscClock> with TickerProviderStateMixin {
  Animation _hourAnimation;
  AnimationController _hourAnimationController;
  double _hoursRotationDegree = 0.0;
  double _hoursAngle = 0.0;
  final List _hoursList = [];
  final List _hours24List = [];

  Animation _minuteAnimation;
  AnimationController _minuteAnimationController;
  double _minuteRotationDegree = 0.0;
  double _minuteAngle = 0.0;
  final List _minuteList = [];

  int _currentHour;

  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);

    //Settings for mobile device to simulate an actual smart display
    if (Platform.isAndroid || Platform.isIOS) {
      //make the clock fullscreen
      SystemChrome.setEnabledSystemUIOverlays([]);
      //set display to landscape
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    }

    _hourAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _hourAnimationController.addListener(() {
      setState(() {});
    });

    _minuteAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _minuteAnimationController.addListener(() {
      setState(() {});
    });

    _generateHours(
      dateTime: _dateTime,
    );

    _generateMin(
      dateTime: _dateTime,
    );

    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DiscClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );

      _rotateHours();
      _rotateMinutes();
    });
  }

  void _rotateHours() {
    if (_hourAnimationController.isAnimating) return;

    //The _currentHour is used to make sure the hour disc does not rotate if it hasn't changed
    if (_currentHour == _dateTime.hour) return;

    //When the _currentHour is different we will update it for the next go around
    _currentHour = _dateTime.hour;

    //The degree amount the disc should rotate to when animating
    _hoursRotationDegree = -60;

    if (_hoursAngle == 0) {
      _hoursAngle = -30;
      return;
    }

    _hourAnimationController.forward().whenComplete(() {
      _hourAnimationController.reset();
      _hourAnimationController.stop();

      //The minute angle should be the ending result
      //After the times changes the disc should be rotated to this degree
      _hoursAngle = -30;
      _generateHours(
        dateTime: _dateTime,
      );
    });
  }

  void _rotateMinutes() {
    if (_minuteAnimationController.isAnimating) return;

    //The degree amount the disc should rotate to when animating
    _minuteRotationDegree = 150;

    if (_minuteAngle == 0) {
      _minuteAngle = 180;
      return;
    }

    _minuteAnimationController.forward().whenComplete(() {
      _minuteAnimationController.reset();
      _minuteAnimationController.stop();

      //The minute angle should be the ending result
      //After the times changes the disc should be rotated to this degree
      _minuteAngle = 180;
      _generateMin(
        dateTime: _dateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness == Brightness.dark
        ? _darkTheme
        : _lightTheme;

    return Container(
        color: theme[_Element.background],
        child: SizedBox(
          width: 100,
          child: _clockStack(),
        ));
  }

  Widget _clockStack() {
    final offset = 100;

    final theme = Theme.of(context).brightness == Brightness.dark
        ? _darkTheme
        : _lightTheme;

    _hourAnimation = CurvedAnimation(
        parent: _hourAnimationController, curve: Curves.easeInOut);
    _hourAnimation = Tween(begin: _hoursAngle, end: _hoursRotationDegree)
        .animate(_hourAnimation);

    _minuteAnimation = CurvedAnimation(
        parent: _minuteAnimationController, curve: Curves.easeInOut);
    _minuteAnimation = Tween(begin: _minuteAngle, end: _minuteRotationDegree)
        .animate(_minuteAnimation);

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      var width = constraints.maxWidth;
      var height = constraints.maxHeight;

      return Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            height: height,
            width: width,
            child: _centerWidget(),
          ),
          Positioned(
            left: -height / 2 - 100,
            top: -(offset / 2),
            bottom: -(offset / 2),
            width: height + offset,
            child: Transform.rotate(
              angle: (_hourAnimation.value) * math.pi / 180,
              child: SpinDisc(
                discTextPainter: DiscTextPainter(
                  fontColor: theme[_Element.text],
                  diameter: height + offset,
                  itemsList:
                      widget.model.is24HourFormat ? _hours24List : _hoursList,
                ),
              ),
            ),
          ),
          Positioned(
            right: -height / 2 - 100,
            top: -(offset / 2),
            bottom: -(offset / 2),
            width: height + offset,
            child: Transform.rotate(
              angle: (_minuteAnimation.value) * math.pi / 180,
              child: SpinDisc(
                flipped: true,
                discTextPainter: DiscTextPainter(
                  fontColor: theme[_Element.text],
                  diameter: height + offset,
                  flipped: true,
                  itemsList: _minuteList,
                ),
              ),
            ),
          ),
          /*FloatingActionButton.extended(
            label: Text("Trigger Animation"),
            onPressed: () {
              _rotateHours();
              _rotateMinutes();
            },
          )*/
        ],
      );
    });
  }

  Widget _centerWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          widget.model.weatherString,
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w500, fontFamily: 'Oswald'),
        ),
        Text(
          widget.model.temperatureString,
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w500, fontFamily: 'Oswald'),
        ),
        Text(
          widget.model.location,
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w500, fontFamily: 'Oswald'),
        ),
        Text(
          DateFormat('MMMM dd').format(_dateTime),
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w500, fontFamily: 'Oswald'),
        )
      ],
    );
  }

  void _generateHours({DateTime dateTime}) {
    //final List<String> hours = [];
    _hoursList.clear();
    _hours24List.clear();
    DateTime startingHour =
        dateTime.subtract(Duration(hours: (itemCount / 2).round()));
    var i = 0;
    while (i < itemCount) {
      _hoursList
          .add(DateFormat('hh').format(startingHour.add(Duration(hours: i))));
      _hours24List
          .add(DateFormat('HH').format(startingHour.add(Duration(hours: i))));
      i++;
    }
  }

  void _generateMin({DateTime dateTime}) {
    _minuteList.clear();
    DateTime startingMinute =
        dateTime.subtract(Duration(minutes: (itemCount / 2).round()));
    var i = 0;
    while (i < itemCount) {
      _minuteList.add(
          DateFormat('mm').format(startingMinute.add(Duration(minutes: i))));
      i++;
    }
  }
}
