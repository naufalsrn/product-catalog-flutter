import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/repository/app_client.dart';
import '../../core/repository/app_repository.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/product_card.dart';
import '../detail/product_detail_screen.dart';
import 'model/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _pageSize = 20;
  static const _loadMoreThreshold = 200.0;

  final AppRepository _repository = AppRepository();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<Product> _products = [];
  Timer? _debounce;
  String _query = '';
  int _nextSkip = 0;
  bool _hasMore = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = _query.isEmpty
          ? await _repository.fetchProducts(limit: _pageSize, skip: 0)
          : await _repository.searchProducts(_query, limit: _pageSize, skip: 0);

      setState(() {
        _products
          ..clear()
          ..addAll(response.products);
        _nextSkip = response.skip + response.products.length;
        _hasMore = response.hasMore;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);

    try {
      final response = _query.isEmpty
          ? await _repository.fetchProducts(limit: _pageSize, skip: _nextSkip)
          : await _repository.searchProducts(_query, limit: _pageSize, skip: _nextSkip);

      setState(() {
        _products.addAll(response.products);
        _nextSkip = response.skip + response.products.length;
        _hasMore = response.hasMore;
        _isLoadingMore = false;
      });
    } on ApiException catch (e) {
      setState(() => _isLoadingMore = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: SnackBarAction(label: 'Retry', onPressed: _loadMore),
        ),
      );
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(value));
  }

  void _search(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed == _query) return;
    _query = trimmed;
    _loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gradientStart,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catalog', style: AppTextStyles.regular(fontSize: 13, color: AppColors.grey)),
                  const SizedBox(height: 4),
                  Text('All Products', style: AppTextStyles.bold(fontSize: 22)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          onSubmitted: _search,
                          decoration: const InputDecoration(
                            hintText: 'Carian...',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _search(_searchController.text),
                            child: const Center(
                              child: Icon(Icons.search, color: AppColors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: GradientBackground(child: _buildBody())),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingView();

    if (_errorMessage != null && _products.isEmpty) {
      return ErrorView(message: _errorMessage!, onRetry: _loadFirstPage);
    }

    if (_products.isEmpty) {
      return const EmptyView(message: 'No products found.');
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.66,
        ),
        itemCount: _products.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _products.length) {
            return const LoadingView();
          }
          final product = _products[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)),
              );
            },
          );
        },
      ),
    );
  }
}
