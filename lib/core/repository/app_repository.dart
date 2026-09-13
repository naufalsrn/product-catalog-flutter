import '../../screens/home/model/product.dart';
import '../../screens/home/model/product_list_response.dart';
import 'app_client.dart';

class AppRepository {
  AppRepository({AppClient? client})
    : _client = client ?? AppClient(baseUrl: 'https://dummyjson.com');

  final AppClient _client;

  Future<ProductListResponse> fetchProducts({int limit = 20, int skip = 0}) async {
    final json = await _client.get(
      '/products',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return ProductListResponse.fromJson(json);
  }

  Future<Product> fetchProductById(int id) async {
    final json = await _client.get('/products/$id');
    return Product.fromJson(json);
  }

  Future<ProductListResponse> searchProducts(String query, {int limit = 20, int skip = 0}) async {
    final json = await _client.get(
      '/products/search',
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
    );
    return ProductListResponse.fromJson(json);
  }
}
