import 'package:carbo/base/design_system/carbo_ds.dart';
import 'package:flutter/material.dart';
import '../../cars/model/cars_list_model.dart';

class CarSummaryCard extends StatelessWidget {
  final CarItem car;
  const CarSummaryCard({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CarboSpacing.x3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: CarboRadius.lgAll,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: CarboRadius.mdAll,
            child: car.imageUrl.isNotEmpty
                ? Image.network(
                    car.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: CarboSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.title.isNotEmpty ? car.title : car.carModel,
                  style: CarboTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (car.carType != null || car.carModelInfo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (car.carType != null) car.carType!.name,
                      if (car.carModelInfo != null) car.carModelInfo!.name,
                    ].join(' • '),
                    style: CarboTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: CarboRadius.mdAll,
      ),
      child: const Icon(Icons.directions_car_outlined, color: Colors.white, size: 28),
    );
  }
}
