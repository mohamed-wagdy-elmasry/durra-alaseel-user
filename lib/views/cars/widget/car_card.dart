import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../base/themes/token.dart';
import '../../../languages/strings.dart';
import '../model/cars_list_model.dart';

class CarCard extends StatelessWidget {
  final CarItem car;
  final String imageUrl;
  final VoidCallback onBookNow;

  const CarCard({
    super.key,
    required this.car,
    required this.imageUrl,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h, left: 4.w, right: 4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Image with Modern Badges
          _buildImageSection(context),
          // Car Info
          _buildInfoSection(context),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // Car Image
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: 190.h,
            width: double.infinity,
            fit: BoxFit.fill,
            placeholder: (context, url) => Container(
              height: 190.h,
              color: Colors.grey[100],
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CustomColor.primary,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 190.h,
              color: Colors.grey[100],
              child: Icon(
                Icons.directions_car_outlined,
                size: 48.sp,
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
        // Gradient Overlay for text readability (optional, but good for white cars)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.05),
                  Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Top Row Badges
        Positioned(
          top: 14.h,
          left: 14.w,
          right: 14.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Branch Name Badge
              if (car.branch?.name != null && car.branch!.name.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: CustomColor.secondary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: CustomColor.secondary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        car.branch!.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              // Year Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: CustomColor.primary,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: CustomColor.primary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Text(
                  car.year.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Type Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800, // Extra Bold
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      [
                        if (car.carType != null) car.carType!.name,
                        if (car.carModelInfo != null) car.carModelInfo!.name,
                      ].join(' • '),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Divider
          Divider(color: Colors.grey[100], height: 1),
          SizedBox(height: 16.h),
          // Price & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Price Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${car.price}',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: CustomColor.primary,
                            fontFamily: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.fontFamily, // Maintain font
                          ),
                        ),
                        TextSpan(
                          text: ' SAR',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: CustomColor.primary,
                            fontFamily: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    Strings.pricePerDay.tr,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Book Button
              ElevatedButton(
                onPressed: onBookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.r), // Pill shape
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      Strings.bookNow.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward_rounded, size: 16.sp),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
