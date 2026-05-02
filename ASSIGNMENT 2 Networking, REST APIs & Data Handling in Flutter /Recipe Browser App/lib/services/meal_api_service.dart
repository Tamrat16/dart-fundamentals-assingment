import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exception.dart';
import 'cache_service.dart';
import '../models/meal_category.dart';
import '../models/meal.dart';

class MealApiService {
  final String _baseUrl = 'www.themealdb.com';
  final String _pathPrefix = '/api/json/v1/1';
  final Duration _timeout = const Duration(seconds: 10);
  final Map<String, String> _headers = {
    'Accept': 'application/json',
  };

  CacheService? _cache;

  Future<CacheService> _getCache() async {
    _cache ??= await CacheService.getInstance();
    return _cache!;
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        'Server returned an error (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<MealCategory>> fetchCategories(
      {bool forceRefresh = false}) async {
    final cacheKey = 'categories';
    final cache = await _getCache();

    if (!forceRefresh && cache.isCached(cacheKey)) {
      final cached = await cache.get(cacheKey);
      if (cached != null) {
        final List<dynamic> list = cached as List<dynamic>;
        return list
            .map((json) => MealCategory.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }

    try {
      final uri = Uri.https(_baseUrl, '$_pathPrefix/categories.php');
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      _checkResponse(response);
      final data = jsonDecode(response.body);
      final List<dynamic> categoriesJson = data['categories'] as List<dynamic>;
      final categories = categoriesJson
          .map((json) => MealCategory.fromJson(json as Map<String, dynamic>))
          .toList();

      await cache.set(cacheKey, categoriesJson);
      return categories;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Meal>> fetchMealsByCategory(String category,
      {bool forceRefresh = false}) async {
    final cacheKey = 'meals_category_$category';
    final cache = await _getCache();

    if (!forceRefresh && cache.isCached(cacheKey)) {
      final cached = await cache.get(cacheKey);
      if (cached != null) {
        final List<dynamic> list = cached as List<dynamic>;
        return list
            .map((json) => Meal.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }

    try {
      final uri =
          Uri.https(_baseUrl, '$_pathPrefix/filter.php', {'c': category});
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      _checkResponse(response);
      final data = jsonDecode(response.body);
      final List<dynamic> mealsJson = data['meals'] as List<dynamic>? ?? [];
      final meals = mealsJson
          .map((map) => Meal(
                idMeal: map['idMeal'] as String,
                strMeal: map['strMeal'] as String,
                strMealThumb: map['strMealThumb'] as String,
                strInstructions: '',
                ingredients: [],
              ))
          .toList();

      // Cache the raw JSON list (without instructions/ingredients for space)
      await cache.set(cacheKey, mealsJson);
      return meals;
    } catch (e) {
      rethrow;
    }
  }

  Future<Meal> fetchMealDetails(String mealId,
      {bool forceRefresh = false}) async {
    final cacheKey = 'meal_details_$mealId';
    final cache = await _getCache();

    if (!forceRefresh && cache.isCached(cacheKey)) {
      final cached = await cache.get(cacheKey);
      if (cached != null) {
        return Meal.fromJson(cached as Map<String, dynamic>);
      }
    }

    try {
      final uri = Uri.https(_baseUrl, '$_pathPrefix/lookup.php', {'i': mealId});
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      _checkResponse(response);
      final data = jsonDecode(response.body);
      final List<dynamic> mealsList = data['meals'] as List<dynamic>? ?? [];
      if (mealsList.isEmpty) {
        throw ApiException('Meal not found', statusCode: 404);
      }
      final mealJson = mealsList.first as Map<String, dynamic>;
      await cache.set(cacheKey, mealJson);
      return Meal.fromJson(mealJson);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Meal>> searchMeals(String query,
      {bool forceRefresh = false}) async {
    final cacheKey = 'search_$query';
    final cache = await _getCache();

    if (!forceRefresh && cache.isCached(cacheKey)) {
      final cached = await cache.get(cacheKey);
      if (cached != null) {
        final List<dynamic> list = cached as List<dynamic>;
        return list
            .map((json) => Meal.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }

    try {
      final uri = Uri.https(_baseUrl, '$_pathPrefix/search.php', {'s': query});
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      _checkResponse(response);
      final data = jsonDecode(response.body);
      final List<dynamic> mealsJson = data['meals'] as List<dynamic>? ?? [];
      await cache.set(cacheKey, mealsJson);
      return mealsJson
          .map((json) => Meal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
