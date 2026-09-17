import 'package:flutter/material.dart';
import '../theme/bkash_theme.dart';

class HoldToConfirmBar extends StatefulWidget {
  final String label;
  final VoidCallback onConfirmed;
  final Duration holdDuration;

  const HoldToConfirmBar({
    super.key,
    this.label = 'পেমেন্ট করতে ট্যাপ করে ধরে রাখুন',
    required this.onConfirmed,
    this.holdDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<HoldToConfirmBar> createState() => _HoldToConfirmBarState();
}

class _HoldToConfirmBarState extends State<HoldToConfirmBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHolding = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isCompleted = true;
        });
        widget.onConfirmed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (_isCompleted) return;
    setState(() {
      _isHolding = true;
    });
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (_isCompleted) return;
    _resetHolding();
  }

  void _onTapCancel() {
    if (_isCompleted) return;
    _resetHolding();
  }

  void _resetHolding() {
    setState(() {
      _isHolding = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        decoration: BoxDecoration(
          color: BkashTheme.primaryPink,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: BkashTheme.primaryPink.withValues(alpha: _isHolding ? 0.6 : 0.3),
              blurRadius: _isHolding ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Animated Fill Progress Layer
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: _controller.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: BkashTheme.deepMagenta,
                      ),
                    ),
                  );
                },
              ),

              // Foreground Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Circular bKash Bird Icon
                    AnimatedScale(
                      scale: _isHolding ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.touch_app_rounded,
                          color: BkashTheme.primaryPink,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isCompleted
                                ? 'পেমেন্ট সম্পন্ন হচ্ছে...'
                                : widget.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final percent =
                                  (_controller.value * 100).toInt();
                              return Text(
                                _isHolding
                                    ? '$percent% ধরে রাখুন...'
                                    : 'Tap and hold to confirm',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
