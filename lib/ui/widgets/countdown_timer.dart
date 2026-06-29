import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_colors.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final TextStyle? textStyle;
  final bool compact;
  
  const CountdownTimer({
    super.key,
    required this.endTime,
    this.textStyle,
    this.compact = false,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    if (mounted) {
      setState(() {
        _remaining = widget.endTime.difference(DateTime.now());
        if (_remaining.isNegative) {
          _remaining = Duration.zero;
          _timer?.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Text(
        'Ended',
        style: widget.textStyle ?? const TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    if (widget.compact) {
      return Text(
        days > 0 
            ? '${days}d ${hours}h'
            : '${hours}h ${minutes}m',
        style: widget.textStyle,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (days > 0) ...[
          _buildTimeUnit(days.toString(), 'D'),
          const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
        _buildTimeUnit(hours.toString().padLeft(2, '0'), 'H'),
        const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'M'),
        const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'S'),
      ],
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: widget.textStyle ?? const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
