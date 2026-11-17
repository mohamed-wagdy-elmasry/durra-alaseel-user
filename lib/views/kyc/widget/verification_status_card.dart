import 'package:flutter/material.dart';
import 'package:carbo/base/utils/basic_import.dart';

/// Verification status card widget
/// 
/// Displays the completion status of KYC verification
/// Shows progress bar and status message
class VerificationStatusCard extends StatelessWidget {
  final bool isComplete;
  final int completionPercentage;

  const VerificationStatusCard({
    Key? key,
    required this.isComplete,
    required this.completionPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;
    final statusColor = isComplete ? Colors.green : Colors.orange;
    final backgroundColor = isComplete ? Colors.green[50] : Colors.orange[50];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[900] : backgroundColor,
      child: Padding(
        padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Row(
              children: [
                Icon(
                  isComplete ? Icons.check_circle : Icons.info,
                  color: statusColor,
                  size: 32,
                ),
                SizedBox(width: Dimensions.defaultHorizontalSize * 0.75),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isComplete
                            ? Strings.verificationComplete
                            : Strings.verificationIncomplete,
                        style: Get.theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isComplete
                            ? Strings.allDocumentsUploaded
                            : Strings.pleaseUploadAllDocuments,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: Dimensions.defaultHorizontalSize * 0.75),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Strings.progress,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$completionPercentage%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completionPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(CustomColor.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
