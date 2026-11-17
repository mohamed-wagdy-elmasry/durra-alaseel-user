import 'package:carbo/base/api/services/basic_services.dart';
import 'package:flutter/material.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/widgets/empty_data_widget.dart';
import '../../../backend/model/extension_history_model.dart';
import '../controller/extension_history_controller.dart';

class ExtensionHistoryScreen extends GetView<ExtensionHistoryController> {
  const ExtensionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.background,
      appBar: AppBar(
        backgroundColor: CustomColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: CustomColor.typography, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextWidget(
          'Extension History',
          typographyStyle: TypographyStyle.titleMedium,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
        actions: [
          Obx(() => controller.isLoading.value
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CustomColor.primary,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.refresh_rounded,
                      color: CustomColor.secondary),
                  onPressed: controller.fetchHistory,
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.data.value;
        if (data == null || data.extensions.isEmpty) {
          return EmptyDataWidget(
            massage: 'No extension history found for this booking.',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.defaultHorizontalSize,
            vertical: Dimensions.verticalSize * 0.5,
          ),
          itemCount: data.extensions.length,
          itemBuilder: (context, index) {
            return _ExtensionCard(record: data.extensions[index]);
          },
        );
      }),
    );
  }
}

class _ExtensionCard extends StatelessWidget {
  final ExtensionRecord record;

  const _ExtensionCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final cur = BasicServices.baseCurCode.value;
    final amount = record.totalCost;
    final amountStr = amount == amount.truncateToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);

    return Card(
      margin: EdgeInsets.only(bottom: Dimensions.verticalSize * 0.4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radius),
        side: BorderSide(color: CustomColor.tertiary),
      ),
      color: CustomColor.whiteColor,
      child: Padding(
        padding: EdgeInsets.all(Dimensions.defaultHorizontalSize * 0.85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _badge(
                  '+${record.extensionDays} day${record.extensionDays == 1 ? '' : 's'}',
                  CustomColor.primary,
                ),
                TextWidget(
                  record.createdAt.toString().substring(0, 10),
                  fontSize: Dimensions.bodySmall,
                  color: CustomColor.secondary,
                ),
              ],
            ),
            SizedBox(height: Dimensions.verticalSize * 0.35),
            _row('New End Date', record.newReturnDate),
            SizedBox(height: Dimensions.verticalSize * 0.2),
            _row('Amount Charged', '$amountStr $cur'),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: TextWidget(
        text,
        fontSize: Dimensions.bodySmall,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(
          label,
          fontSize: Dimensions.bodySmall,
          color: CustomColor.secondary,
        ),
        TextWidget(
          value,
          fontSize: Dimensions.bodySmall,
          fontWeight: FontWeight.w600,
          color: CustomColor.typography,
        ),
      ],
    );
  }
}
