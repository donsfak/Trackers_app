import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/utils/utils.dart'; // Ensure app_notifications is exported here or import it
import 'package:google_fonts/google_fonts.dart';

class FocusScreen extends ConsumerStatefulWidget {
  final Task? task;

  const FocusScreen({super.key, this.task});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  Timer? _timer;
  static const int _focusTime = 25 * 60;
  static const int _shortBreakTime = 5 * 60;
  static const int _longBreakTime = 15 * 60;

  int _remainingTime = _focusTime;
  int _initialTime = _focusTime;
  bool _isRunning = false;
  String _mode = 'Focus'; // Focus, Short Break, Long Break

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _stopTimer();
        _onComplete();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remainingTime = _initialTime;
    });
  }

  void _setMode(String mode, int time) {
    _stopTimer();
    setState(() {
      _mode = mode;
      _initialTime = time;
      _remainingTime = time;
    });
  }

  Future<void> _onComplete() async {
    // Notify user
    await AppNotifications.scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: "$_mode Session Complete!",
      body: "Time to ${_mode == 'Focus' ? 'take a break' : 'focus'}!",
      scheduledTime: DateTime.now().add(const Duration(seconds: 1)),
    );

    if (mounted) {
      AppAlert.displaysnackbar(context, "$_mode session finished!");
    }
  }

  String _formatTime(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double percent =
        _initialTime == 0 ? 0 : (_initialTime - _remainingTime) / _initialTime;

    return Scaffold(
      backgroundColor: Colors.black, // Premium Dark
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _mode,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (widget.task != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Focusing on: ${widget.task!.title}",
                  style:
                      GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),
            CircularPercentIndicator(
              radius: 140.0,
              lineWidth: 15.0,
              percent:
                  percent, // Progress moves forward? Or backward? Usually backward for countdown (1.0 -> 0.0) or forward (0.0 -> 1.0)
              // Let's do countdown visual: full to empty.
              // So percent = _remainingTime / _initialTime
              // Use logic below in widget
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(_remainingTime),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 60.0,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _isRunning ? "Running" : "Paused",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              progressColor:
                  _mode == 'Focus' ? Colors.cyanAccent : Colors.greenAccent,
              backgroundColor: Colors.grey[900]!,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animateFromLastPercent: true,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: _isRunning ? Icons.pause : Icons.play_arrow,
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(width: 20),
                _buildControlButton(
                  icon: Icons.refresh,
                  onPressed: _resetTimer,
                  color: Colors.white54,
                  size: 40,
                ),
              ],
            ),
            const Spacer(),
            // Mode Selectors
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildModeButton("Focus", _focusTime),
                  _buildModeButton("Short Break", _shortBreakTime),
                  _buildModeButton("Long Break", _longBreakTime),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required double size,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        iconSize: size,
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildModeButton(String title, int time) {
    final isSelected = _mode == title;
    return GestureDetector(
      onTap: () => _setMode(title, time),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.cyanAccent : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 4,
              width: 4,
              decoration: const BoxDecoration(
                color: Colors.cyanAccent,
                shape: BoxShape.circle,
              ),
            )
        ],
      ),
    );
  }
}
