part of 'history_screen.dart';

class HistoryMobileScreen extends GetView<HistoryController> {
  const HistoryMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarboColors.background,
      appBar: AppBar(
        backgroundColor: CarboColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(CarboIcons.back, color: CarboColors.textPrimary, size: 20),
        ),
        title: Text(Strings.history.tr, style: CarboTypography.headlineSmall),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: CarboColors.divider),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading) return const Center(child: Loader());
        if (controller.historyList.isEmpty) return const EmptyDataWidget();
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: CarboSpacing.x5,
            vertical: CarboSpacing.x4,
          ),
          itemCount: controller.historyList.length,
          separatorBuilder: (_, __) => const SizedBox(height: CarboSpacing.x3),
          itemBuilder: (_, index) => HistoryCard(index),
        );
      }),
    );
  }
}
