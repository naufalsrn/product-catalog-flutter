import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/repository/app_client.dart';
import '../../core/repository/app_repository.dart';
import '../../widgets/error_view.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/loading_view.dart';
import '../home/model/product.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const _reviewsPageSize = 3;

  final AppRepository _repository = AppRepository();

  Product? _product;
  String? _errorMessage;
  bool _isLoading = true;
  int _selectedImageIndex = 0;
  int _visibleReviewCount = _reviewsPageSize;
  bool _sortReviewsDescending = true;

  List<Review> _sortedReviews(List<Review> reviews) {
    return [...reviews]..sort(
      (a, b) => _sortReviewsDescending ? b.rating.compareTo(a.rating) : a.rating.compareTo(b.rating),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final product = await _repository.fetchProductById(widget.productId);
      setState(() {
        _product = product;
        _selectedImageIndex = 0;
        _visibleReviewCount = _reviewsPageSize;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(child: GradientBackground(child: _buildBody())),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingView();

    if (_errorMessage != null || _product == null) {
      return ErrorView(message: _errorMessage ?? 'Something went wrong.', onRetry: _load);
    }

    final product = _product!;
    final gallery = product.images.isNotEmpty ? product.images : [product.thumbnail];
    final selectedImage = gallery[_selectedImageIndex.clamp(0, gallery.length - 1)];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                selectedImage,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image_outlined, color: AppColors.grey, size: 48),
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title, style: AppTextStyles.bold(fontSize: 18, color: AppColors.white)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: AppTextStyles.bold(fontSize: 20, color: AppColors.white),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: AppTextStyles.medium(fontSize: 14, color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Description', style: AppTextStyles.semiBold(fontSize: 14, color: AppColors.white)),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: AppTextStyles.regular(fontSize: 14, color: AppColors.white),
                ),
                if (product.shippingInformation.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          product.shippingInformation,
                          style: AppTextStyles.medium(fontSize: 13, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ],
                if (gallery.length > 1) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedImageIndex;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedImageIndex = index),
                          child: Container(
                            width: 72,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? AppColors.black : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              gallery[index],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image_outlined, color: AppColors.grey);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (product.reviews.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Reviews (${product.reviews.length})',
                          style: AppTextStyles.semiBold(fontSize: 14, color: AppColors.white),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => setState(() => _sortReviewsDescending = !_sortReviewsDescending),
                        icon: Icon(
                          _sortReviewsDescending ? Icons.arrow_downward : Icons.arrow_upward,
                          size: 14,
                          color: AppColors.white,
                        ),
                        label: Text(
                          _sortReviewsDescending ? 'Highest rated' : 'Lowest rated',
                          style: AppTextStyles.medium(fontSize: 12, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._sortedReviews(product.reviews)
                      .take(_visibleReviewCount)
                      .map((review) => _ReviewTile(review: review)),
                  if (_visibleReviewCount < product.reviews.length)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _visibleReviewCount = (_visibleReviewCount + _reviewsPageSize).clamp(
                              0,
                              product.reviews.length,
                            );
                          });
                        },
                        child: Text(
                          'Show more (${product.reviews.length - _visibleReviewCount} left)',
                          style: AppTextStyles.semiBold(fontSize: 13, color: AppColors.white),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.reviewerName,
                  style: AppTextStyles.semiBold(fontSize: 13),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(review.comment, style: AppTextStyles.regular(fontSize: 13)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
          ),
          Expanded(
            child: Text(
              'Product Details',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bold(fontSize: 16, color: AppColors.white),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
