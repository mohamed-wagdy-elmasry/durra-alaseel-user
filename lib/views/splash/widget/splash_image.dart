import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../base/api/services/basic_services.dart';

class SplashImage extends StatelessWidget {
  const SplashImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final url = BasicServices.splashImage.value;
        if (url.isEmpty) {
          return const SizedBox.shrink();
        }
        return CachedNetworkImage(
          imageUrl: url,
          placeholder: (context, url) => const SizedBox.shrink(),
          errorWidget: (context, url, error) => const SizedBox.shrink(),
          fit: BoxFit.cover,
        );
      },
    );
  }
}
