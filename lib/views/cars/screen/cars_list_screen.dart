import 'package:carbo/views/drawer/screen/drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../base/themes/token.dart';
import '../../../base/widgets/loader.dart';
import '../../../languages/strings.dart';
import '../../../routes/routes.dart';
import '../controller/cars_controller.dart';
import '../model/cars_list_model.dart';
import '../widget/car_card.dart';

class CarsListScreen extends StatelessWidget {
  const CarsListScreen({super.key});

  CarsController get controller => Get.find<CarsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerScreen(),
      body: Container(
        color: CustomColor.background,
        child: SafeArea(
          child: Column(
            children: [
              // Custom Modern Header
              _buildCustomHeader(context),
              
              // Loading or Body
              Expanded(
                child: Obx(() => controller.isLoading
                    ? const Loader()
                    : _buildContent(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Drawer Menu Button & Title
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      color: Colors.black87,
                      size: 20.sp,
                    ),
                  ),
                  tooltip: 'Menu',
                  style: IconButton.styleFrom(
                      padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.availableCars.tr,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: CustomColor.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Find your perfect ride',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Action Buttons (Filter Only)
          Row(
            children: [
              // Filter Button
              Obx(() {
                 final hasFilters = controller.selectedCarTypeId.value != null ||
                    controller.selectedCarModelId.value != null ||
                    controller.selectedBranchId.value != null;
                return _buildHeaderActionButton(
                  icon: Icons.tune_rounded,
                  isActive: hasFilters,
                  onTap: () => _showFilterSheet(context),
                  showDot: hasFilters,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeaderActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isActive ? CustomColor.primary : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: isActive 
                    ? CustomColor.primary.withOpacity(0.3) 
                    : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.black87,
              size: 22.sp,
            ),
          ),
          if (showDot)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : CustomColor.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // Active Filters Chips
        _buildActiveFilters(context),
        // Cars List
        Expanded(
          child: Obx(() {
            if (controller.cars.isEmpty) {
              return _buildEmptyState(context);
            }
            return RefreshIndicator(
              onRefresh: () async => controller.refreshCars(),
              edgeOffset: 10.h,
              color: CustomColor.primary,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                itemCount: controller.cars.length + 1,
                itemBuilder: (context, index) {
                  if (index == controller.cars.length) {
                    // Load more indicator
                    return _buildLoadMoreWidget();
                  }
                  final car = controller.cars[index];
                  return CarCard(
                    car: car,
                    imageUrl: controller.getCarImageUrl(car),
                    onBookNow: () => _onBookNow(car),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActiveFilters(BuildContext context) {
    return Obx(() {
      final hasFilters = controller.selectedCarTypeId.value != null ||
          controller.selectedCarModelId.value != null ||
          controller.selectedBranchId.value != null;

      if (!hasFilters) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            // Car Type Filter Chip
            if (controller.selectedCarTypeId.value != null)
              _buildFilterChip(
                label: controller.carTypes
                        .firstWhereOrNull(
                            (t) => t.id == controller.selectedCarTypeId.value)
                        ?.name ??
                    '',
                onRemove: () => controller.setCarTypeFilter(null),
              ),
            // Car Model Filter Chip
            if (controller.selectedCarModelId.value != null)
              _buildFilterChip(
                label: controller.carModels
                        .firstWhereOrNull(
                            (m) => m.id == controller.selectedCarModelId.value)
                        ?.name ??
                    '',
                onRemove: () => controller.setCarModelFilter(null),
              ),
            // Branch Filter Chip
            if (controller.selectedBranchId.value != null)
              _buildFilterChip(
                label: controller.branches
                        .firstWhereOrNull(
                            (b) => b.id == controller.selectedBranchId.value)
                        ?.name ??
                    '',
                onRemove: () => controller.setBranchFilter(null),
              ),
            // Clear All Button
            TextButton.icon(
              onPressed: controller.clearFilters,
              icon: Icon(Icons.clear_all, size: 18.sp),
              label: Text(
                Strings.clearFilters.tr,
                style: TextStyle(fontSize: 12.sp),
              ),
              style: TextButton.styleFrom(
                foregroundColor: CustomColor.primary,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(fontSize: 12.sp),
      ),
      deleteIcon: Icon(Icons.close, size: 16.sp),
      onDeleted: onRemove,
      backgroundColor: CustomColor.primary.withOpacity(0.1),
      deleteIconColor: CustomColor.primary,
      labelStyle: TextStyle(color: CustomColor.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: CustomColor.primary.withOpacity(0.3)),
      ),
    );
  }

   Widget _buildEmptyState(BuildContext context) {
    final hasFilters = controller.selectedCarTypeId.value != null ||
        controller.selectedCarModelId.value != null ||
        controller.selectedBranchId.value != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            Strings.noCarsAvailable.tr,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24.h),
          // Refresh Button
          SizedBox(
            height: 44.h,
            child: ElevatedButton.icon(
              onPressed: () => controller.refreshCars(),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
              ),
              icon: Icon(Icons.refresh_rounded, size: 20.sp),
              label: Text(
                Strings.refresh.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (hasFilters) ...[
            SizedBox(height: 12.h),
            TextButton(
              onPressed: controller.clearFilters,
              child: Text(Strings.clearFilters.tr),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadMoreWidget() {
    return Obx(() {
      if (controller.currentPage.value >= controller.totalPages.value) {
        return const SizedBox.shrink();
      }
      if (controller.isLoadingMore) {
        return Padding(
          padding: EdgeInsets.all(16.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      return Padding(
        padding: EdgeInsets.all(16.h),
        child: Center(
          child: TextButton(
            onPressed: controller.loadMoreCars,
            child: const Text('Load More'),
          ),
        ),
      );
    });
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => FilterSheet(controller: controller),
    );
  }

  void _onBookNow(CarItem car) {
    // Navigate to booking screen with car details
    Get.toNamed(Routes.bookingScreen, arguments: {
      'carId': car.id,
      'car': car,
    });
  }
}

class FilterSheet extends StatelessWidget {
  final CarsController controller;

  const FilterSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.filterBy.tr,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Sort Button
          Text(
            Strings.sortByPrice.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => Row(
                children: [
                  _buildSortOption(
                    context,
                    label: Strings.priceLowToHigh.tr,
                    value: 'price_asc',
                    isSelected: controller.sortOrder.value == 'price_asc',
                  ),
                  SizedBox(width: 12.w),
                  _buildSortOption(
                    context,
                    label: Strings.priceHighToLow.tr,
                    value: 'price_desc',
                    isSelected: controller.sortOrder.value == 'price_desc',
                  ),
                ],
              )),
          SizedBox(height: 20.h),

          // Car Type Filter
          Text(
            Strings.carType.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => _buildChipGroup<CarTypeFilter>(
                items: controller.carTypes,
                selectedItem: controller.carTypes.firstWhereOrNull(
                    (t) => t.id == controller.selectedCarTypeId.value),
                itemLabel: (item) => item.name,
                onSelected: (item) => controller.setCarTypeFilter(item?.id),
              )),
          SizedBox(height: 16.h),

          // Car Model Filter
          Text(
            Strings.carModel.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => _buildChipGroup<CarModelFilter>(
                items: controller.filteredCarModels,
                selectedItem: controller.filteredCarModels.firstWhereOrNull(
                    (m) => m.id == controller.selectedCarModelId.value),
                itemLabel: (item) => item.name,
                onSelected: (item) => controller.setCarModelFilter(item?.id),
              )),
          SizedBox(height: 16.h),

          // Branch Filter
          Text(
            'Branch',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => _buildChipGroup<BranchFilter>(
                items: controller.branches,
                selectedItem: controller.branches.firstWhereOrNull(
                    (b) => b.id == controller.selectedBranchId.value),
                itemLabel: (item) => item.name,
                onSelected: (item) => controller.setBranchFilter(item?.id),
              )),
          SizedBox(height: 24.h),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                Strings.confirm.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10.h),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context, {
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setSortOrder(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? CustomColor.primary.withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? CustomColor.primary : Colors.grey[300]!,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                value == 'price_asc'
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16.sp,
                color: isSelected ? CustomColor.primary : Colors.grey[600],
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isSelected ? CustomColor.primary : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipGroup<T>({
    required List<T> items,
    required T? selectedItem,
    required String Function(T) itemLabel,
    required Function(T?) onSelected,
  }) {
    if (items.isEmpty) {
      return Text(
        "No options available",
        style: TextStyle(
            color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12.sp),
      );
    }
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items.map((item) {
        final isSelected = selectedItem == item;
        return ChoiceChip(
          label: Text(
            itemLabel(item),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 12.sp,
            ),
          ),
          selected: isSelected,
          onSelected: (bool selected) {
            onSelected(selected ? item : null);
          },
          selectedColor: CustomColor.primary,
          backgroundColor: Colors.grey[200],
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
