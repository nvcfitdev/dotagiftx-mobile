import 'dart:async';

import 'package:dotagiftx_mobile/domain/models/dota_item_model.dart';
import 'package:dotagiftx_mobile/presentation/core/resources/app_colors.dart';
import 'package:dotagiftx_mobile/presentation/core/utils/number_format_utils.dart';
import 'package:dotagiftx_mobile/presentation/core/widgets/dotagiftx_image_view.dart';
import 'package:dotagiftx_mobile/presentation/dota_item_detail/dota_item_detail_view.dart';
import 'package:dotagiftx_mobile/presentation/home/subviews/rarity_text_view.dart';
import 'package:flutter/material.dart';

class DotaItemCardView extends StatelessWidget {
  final DotaItemModel item;

  const DotaItemCardView({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Card content (background)
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Item Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: DotagiftxImageView(
                        imageUrl: item.image ?? '',
                        rarity: item.rarity ?? '',
                        width: 60,
                        height: 60,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Item Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                item.hero ?? '',
                                style: const TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              RarityTextView(rarity: item.rarity ?? ''),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Text(
                      '\$${NumberFormatUtils.formatDecimal(item.lowestAsk, 2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // InkWell overlay (foreground)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _navigateToItemDetail(context),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToItemDetail(BuildContext context) {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => DotaItemDetailView(item: item)),
      ),
    );
  }
}
