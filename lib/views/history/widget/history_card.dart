part of '../screen/history_screen.dart';

class HistoryCard extends GetView<HistoryController> {
  final int index;
  const HistoryCard(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = controller.historyList[index];
    final cars = info.cars;

    final enValue = cars.carTitle['en'];
    final carTitle = (enValue is Map ? enValue['car_title'] : enValue)?.toString() ?? 'N/A';
    final carModel = cars.carModel?.toString() ?? '';
    final year = cars.year != 0 ? cars.year.toString() : '';

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.bookingDetailsScreen, arguments: {'booking': info}),
      child: Container(
        decoration: BoxDecoration(
          color: CarboColors.surface,
          borderRadius: CarboRadius.lgAll,
          boxShadow: CarboShadow.card,
        ),
        child: ClipRRect(
          borderRadius: CarboRadius.lgAll,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'car_hero_${info.id}',
                child: SizedBox(
                  width: 100,
                  height: 110,
                  child: Image.network(
                    cars.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      color: CarboColors.background,
                      child: const Center(
                        child: Icon(CarboIcons.car, color: CarboColors.textDisabled, size: 32),
                      ),
                    ),
                  ),
                ),
              ),
              // Info section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(CarboSpacing.x3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row + status badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              carTitle,
                              style: CarboTypography.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: CarboSpacing.x2),
                          _buildStatusBadge(info.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Year
                      if (year.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          year,
                          style: CarboTypography.caption.copyWith(color: CarboColors.textDisabled),
                        ),
                      ],
                      const SizedBox(height: CarboSpacing.x2),
                      const Divider(height: 1, color: CarboColors.divider),
                      const SizedBox(height: CarboSpacing.x2),
                      // Amount + date
                      Row(
                        children: [
                          Text(
                            '${info.amount ?? 0} ${BasicServices.baseCurCode}',
                            style: CarboTypography.labelMedium.copyWith(
                              color: CarboColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 11, color: CarboColors.textSecondary),
                              const SizedBox(width: 3),
                              Text(
                                DateFormat('d MMM yyyy').format(info.pickupDate),
                                style: CarboTypography.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    final Color bg;
    final Color fg;
    final String label;

    if (status == 1) {
      bg = CarboColors.warningBg;
      fg = CarboColors.warning;
      label = Strings.pending;
    } else if (status == 2) {
      bg = CarboColors.infoBg;
      fg = CarboColors.info;
      label = Strings.ongoing;
    } else if (status == 3) {
      bg = CarboColors.successBg;
      fg = CarboColors.success;
      label = Strings.complete;
    } else {
      bg = CarboColors.errorBg;
      fg = CarboColors.error;
      label = Strings.reject;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: CarboSpacing.x2, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: CarboRadius.fullAll),
      child: Text(
        label.tr,
        style: CarboTypography.caption.copyWith(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}
