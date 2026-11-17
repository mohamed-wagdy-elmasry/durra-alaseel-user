import 'package:flutter/material.dart';
import '../design_system/carbo_ds.dart';

class InlineErrorWidget extends StatelessWidget {
  final String message;
  final EdgeInsets? padding;
  final VoidCallback? onDismiss;

  const InlineErrorWidget({
    Key? key,
    required this.message,
    this.padding,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: message.isNotEmpty ? 1.0 : 0.0,
      duration: CarboDuration.normal,
      child: message.isNotEmpty
          ? Container(
              padding: padding ?? EdgeInsets.all(CarboSpacing.x4),
              decoration: BoxDecoration(
                border: Border.all(color: CarboColors.error, width: 1.5),
                borderRadius: CarboRadius.mdAll,
                color: CarboColors.errorBg,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_rounded,
                    color: CarboColors.error,
                    size: 20,
                  ),
                  SizedBox(width: CarboSpacing.x3),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: CarboColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  if (onDismiss != null)
                    GestureDetector(
                      onTap: onDismiss,
                      child: Icon(
                        Icons.close_rounded,
                        color: CarboColors.error,
                        size: 20,
                      ),
                    ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
