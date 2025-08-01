import 'package:dotagiftx_mobile/core/utils/string_utils.dart';
import 'package:dotagiftx_mobile/presentation/core/base/view_cubit_mixin.dart';
import 'package:dotagiftx_mobile/presentation/core/utils/rarity_utils.dart';
import 'package:dotagiftx_mobile/presentation/core/viewmodels/dotagiftx_image_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DotagiftxImageView extends StatelessWidget
    with ViewCubitMixin<DotagiftxImageCubit> {
  final String imageUrl;
  final String? rarity;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? scale;
  final Widget? errorWidget;
  final Widget? loadingWidget;
  final double? borderWidth;

  const DotagiftxImageView({
    required this.imageUrl,
    this.rarity,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.scale,
    this.errorWidget,
    this.loadingWidget,
    this.borderWidth,
    super.key,
  });

  @override
  Widget buildView(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final resolvedScale = scale ?? devicePixelRatio;
    final screenSize = MediaQuery.of(context).size;

    final image = BlocBuilder<DotagiftxImageCubit, String>(
      builder: (context, state) {
        String resolvedUrl;
        if (width != null && height != null) {
          // Handle double.infinity values by using screen dimensions
          final resolvedWidth =
              width == double.infinity ? screenSize.width : width!;
          final resolvedHeight =
              height == double.infinity ? screenSize.height : height!;

          final scaledWidth = (resolvedScale * resolvedWidth).round();
          final scaledHeight = (resolvedScale * resolvedHeight).round();
          resolvedUrl = '$state${scaledWidth}x$scaledHeight/$imageUrl';
        } else {
          resolvedUrl = '$state$imageUrl';
        }

        return StringUtils.isNullOrEmpty(imageUrl)
            ? errorWidget ?? const Icon(Icons.broken_image)
            : Image.network(
              resolvedUrl,
              width: width,
              height: height,
              fit: fit,
              scale: resolvedScale,
              errorBuilder:
                  (context, error, stackTrace) =>
                      errorWidget ?? const Icon(Icons.broken_image),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return loadingWidget ??
                    const Center(child: CircularProgressIndicator());
              },
            );
      },
    );

    // Apply rarity border if rarity is provided
    final borderColor = RarityUtils.getRarityColor(rarity);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: borderWidth ?? 2.0,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      // Slightly smaller to account for border
      child: ClipRRect(borderRadius: BorderRadius.circular(4), child: image),
    );
  }
}
