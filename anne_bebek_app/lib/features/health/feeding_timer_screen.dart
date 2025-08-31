import 'dart:async';
import 'package:flutter/material.dart';

class FeedingTimerScreen extends StatefulWidget {
  const FeedingTimerScreen({super.key});

  @override
  State<FeedingTimerScreen> createState() => _FeedingTimerScreenState();
}

class _FeedingTimerScreenState extends State<FeedingTimerScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _result = '00:00';
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (Timer timer) {
      if (_stopwatch.isRunning) {
        setState(() {
          _result =
              '${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _startStop() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
      } else {
        _stopwatch.start();
      }
      _isRunning = _stopwatch.isRunning;
    });
  }

  void _reset() {
    setState(() {
      _stopwatch.reset();
      _result = '00:00';
    });
  }

  void _save() {
    Navigator.pop(context, _stopwatch.elapsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emzirme Zamanlayıcı')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_result, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: _reset,
                  child: const Icon(Icons.refresh),
                ),
                FloatingActionButton(
                  onPressed: _startStop,
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                ),
                FloatingActionButton(
                  onPressed: _save,
                  child: const Icon(Icons.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
