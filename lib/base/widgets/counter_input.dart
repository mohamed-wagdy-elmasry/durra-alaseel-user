import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carbo/base/design_system/carbo_ds.dart';

/// A reusable counter input with (−) / (+) buttons.
///
/// The [−] / [+] buttons are direction-locked to LTR (spatial convention),
/// but the count + suffix text follows the app's text direction so
/// Arabic shows "أيام 4" and English shows "4 Days".
///
/// ```dart
/// CounterInput(
///   controller: daysController,
///   label: 'Rental Days',
///   suffixBuilder: (count) {
///     if (count == 1) return 'يوم';
///     if (count == 2) return 'يومان';
///     if (count <= 10) return 'أيام';
///     return 'يومًا';
///   },
///   min: 1,
///   max: 90,
/// )
/// ```
class CounterInput extends StatefulWidget {
  const CounterInput({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.suffixText,
    this.suffixBuilder,
    this.min = 0,
    this.max = 999,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? suffixText;
  final String? Function(int count)? suffixBuilder;
  final int min;
  final int max;

  @override
  State<CounterInput> createState() => _CounterInputState();
}

class _CounterInputState extends State<CounterInput> {
  late int _count;
  int _animKey = 0;
  bool _minusHeld = false;
  bool _plusHeld = false;

  @override
  void initState() {
    super.initState();
    final parsed = int.tryParse(widget.controller.text);
    _count = (parsed != null && parsed >= widget.min) ? parsed : widget.min;
    widget.controller.text = _count.toString();
    widget.controller.addListener(_syncFromController);
  }

  void _syncFromController() {
    final v = int.tryParse(widget.controller.text) ?? 0;
    if (v != _count) setState(() => _count = v);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    super.dispose();
  }

  bool get _atMin => _count <= widget.min;
  bool get _atMax => _count >= widget.max;

  void _change(int delta) {
    final next = _count + delta;
    if (next < widget.min || next > widget.max) return;
    HapticFeedback.lightImpact();
    setState(() {
      _count = next;
      _animKey++;
    });
    widget.controller.text = _count.toString();
  }

  String? get _currentSuffix {
    if (_count <= 0) return null;
    if (widget.suffixBuilder != null) return widget.suffixBuilder!(_count);
    return widget.suffixText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label (follows app direction) ─────────────────────────────
        Text(widget.label, style: CarboTypography.labelMedium),
        SizedBox(height: CarboSpacing.x2),

        // ── Counter row (buttons LTR-locked, content natural) ────────
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: CarboColors.surface,
              borderRadius: CarboRadius.mdAll,
              border: Border.all(color: CarboColors.border),
              boxShadow: CarboShadow.soft,
            ),
            child: Row(
              children: [
                // ── Minus button ────────────────────────────────────
                _StepperButton(
                  icon: Icons.remove_rounded,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(CarboRadius.md),
                    bottomLeft: Radius.circular(CarboRadius.md),
                  ),
                  disabled: _atMin,
                  held: _minusHeld,
                  activeBg: CarboColors.errorBg,
                  activeFg: CarboColors.primary,
                  onDown: () => setState(() => _minusHeld = true),
                  onUp: () {
                    setState(() => _minusHeld = false);
                    _change(-1);
                  },
                  onCancel: () => setState(() => _minusHeld = false),
                ),

                _verticalDivider(),

                // ── Count + suffix (follows app direction) ──────────
                Expanded(
                  child: Directionality(
                    textDirection: Directionality.of(context),
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(_animKey),
                        tween: Tween(begin: 0.78, end: 1.0),
                        duration: CarboDuration.slow,
                        curve: Curves.elasticOut,
                        builder: (_, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: Directionality.of(context),
                          children: [
                            Text(
                              '$_count',
                              style: CarboTypography.headlineSmall.copyWith(
                                color: CarboColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_currentSuffix != null) ...[
                              SizedBox(width: 6.w),
                              Text(
                                _currentSuffix!,
                                style: CarboTypography.bodySmall.copyWith(
                                  color: CarboColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                _verticalDivider(),

                // ── Plus button ──────────────────────────────────────
                _StepperButton(
                  icon: Icons.add_rounded,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(CarboRadius.md),
                    bottomRight: Radius.circular(CarboRadius.md),
                  ),
                  disabled: _atMax,
                  held: _plusHeld,
                  activeBg: CarboColors.successBg,
                  activeFg: CarboColors.success,
                  onDown: () => setState(() => _plusHeld = true),
                  onUp: () {
                    setState(() => _plusHeld = false);
                    _change(1);
                  },
                  onCancel: () => setState(() => _plusHeld = false),
                ),
              ],
            ),
          ),
        ),

        // ── Hint (follows app direction) ───────────────────────────────
        if (widget.hintText != null) ...[
          SizedBox(height: CarboSpacing.x1),
          Text(
            widget.hintText!,
            style: CarboTypography.caption.copyWith(
              color: CarboColors.textDisabled,
            ),
          ),
        ],
      ],
    );
  }

  Widget _verticalDivider() => VerticalDivider(
        width: 1,
        thickness: 1,
        color: CarboColors.borderLight,
        indent: 12.h,
        endIndent: 12.h,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Private stepper button
// ─────────────────────────────────────────────────────────────────────────────

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.borderRadius,
    required this.disabled,
    required this.held,
    required this.activeBg,
    required this.activeFg,
    required this.onDown,
    required this.onUp,
    required this.onCancel,
  });

  final IconData icon;
  final BorderRadius borderRadius;
  final bool disabled;
  final bool held;
  final Color activeBg;
  final Color activeFg;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final Color bg =
        disabled ? Colors.transparent : held ? activeBg : Colors.transparent;
    final Color fg =
        disabled ? CarboColors.textDisabled : held ? activeFg : CarboColors.textPrimary;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => onDown(),
      onTapUp: disabled ? null : (_) => onUp(),
      onTapCancel: disabled ? null : onCancel,
      child: AnimatedContainer(
        duration: CarboDuration.fast,
        width: 56.h,
        height: 56.h,
        decoration: BoxDecoration(color: bg, borderRadius: borderRadius),
        child: Icon(icon, size: 22.r, color: fg),
      ),
    );
  }
}