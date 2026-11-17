part of '../screen/preview_screen.dart';

class PaymentSelectionWidget extends GetView<PreviewController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.payWIth.tr,
            style: CarboTypography.titleLarge,
          ),
          const SizedBox(height: CarboSpacing.x3),
          Row(
            children: [
              Expanded(
                child: _PaymentCard(
                  icon: Icons.payments_outlined,
                  label: Strings.cashPayment.tr,
                  isSelected: controller.selectedMethod.value == 0,
                  onTap: () => controller.changePaymentMethod(0),
                ),
              ),
              const SizedBox(width: CarboSpacing.x3),
              Expanded(
                child: _PaymentCard(
                  icon: CarboIcons.payment,
                  label: Strings.onlinePayment.tr,
                  isSelected: controller.selectedMethod.value == 1,
                  onTap: () => controller.changePaymentMethod(1),
                ),
              ),
            ],
          ),
          if (controller.selectedMethod.value == 1) ...[
            const SizedBox(height: CarboSpacing.x3),
            CustomDropDown<PaymentGateway>(
              decoration: BoxDecoration(
                color: CarboColors.surface,
                borderRadius: CarboRadius.mdAll,
                boxShadow: CarboShadow.card,
              ),
              itemsList: controller.paymentGatewayList,
              selectMethod: RxString(Strings.selectMethod),
              onChanged: (v) {
                controller.selectPaymentGateway.value = v!;
                controller.paymentTypes.value = v.type;
                controller.currencyList.clear();
                for (final c in v.currencies) {
                  controller.currencyList.add(
                    Currency(
                      id: c.id,
                      name: c.name,
                      updatedAt: c.updatedAt,
                      createdAt: c.createdAt,
                      image: c.image,
                      alias: c.alias,
                      currencyCode: c.currencyCode,
                      currencySymbol: c.currencySymbol,
                      fixedCharge: c.fixedCharge,
                      maxLimit: c.maxLimit,
                      minLimit: c.maxLimit,
                      paymentGatewayId: c.paymentGatewayId,
                      percentCharge: c.percentCharge,
                      rate: c.rate,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: CarboSpacing.x3),
            CustomDropDown<Currency>(
              decoration: BoxDecoration(
                color: CarboColors.surface,
                borderRadius: CarboRadius.mdAll,
                boxShadow: CarboShadow.card,
              ),
              itemsList: controller.currencyList,
              selectMethod: RxString(Strings.selectCurrency),
              onChanged: (v) {
                controller.selectedCurrency.value = v!;
                controller.alias.value = v.alias;
                controller.currencyName.value = v.name;
                controller.exRent.value = v.rate.toDouble();
                controller.percentCharge.value = v.percentCharge.toDouble();
                controller.fixeCharge.value = v.fixedCharge.toDouble();
                controller.calculateAllCharges();
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: CarboDuration.normal,
        padding: const EdgeInsets.symmetric(
          vertical: CarboSpacing.x4,
          horizontal: CarboSpacing.x3,
        ),
        decoration: BoxDecoration(
          color: isSelected ? CarboColors.primaryLight : CarboColors.surface,
          borderRadius: CarboRadius.lgAll,
          border: Border.all(
            color: isSelected ? CarboColors.primary : CarboColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? CarboShadow.primaryGlow : CarboShadow.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: CarboDuration.fast,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? CarboColors.primary : CarboColors.background,
                borderRadius: CarboRadius.smAll,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : CarboColors.textSecondary,
              ),
            ),
            const SizedBox(height: CarboSpacing.x2),
            Text(
              label,
              style: CarboTypography.labelLarge.copyWith(
                color: isSelected ? CarboColors.primary : CarboColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
