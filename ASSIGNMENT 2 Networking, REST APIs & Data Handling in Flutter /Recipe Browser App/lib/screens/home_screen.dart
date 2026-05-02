import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:recipe_browser/services/meal_api_service.dart';
import 'package:recipe_browser/services/api_exception.dart';
import 'package:recipe_browser/services/cache_service.dart';
import 'package:recipe_browser/models/meal_category.dart';
import 'package:recipe_browser/models/meal.dart';
import 'category_screen.dart';
import 'meal_detail_screen.dart';
import '../widgets/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<MealCategory>> _futureCategories;
  final MealApiService _apiService = MealApiService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _searchQuery = '';
  bool _isSearching = false;

  // Pagination for search results
  List<Meal> _allSearchResults = [];
  List<Meal> _displayedResults = [];
  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  Future<List<Meal>>? _searchFuture;
  bool _isFromCache = false;

  @override
  void initState() {
    super.initState();
    _futureCategories = _fetchCategories();
  }

  Future<List<MealCategory>> _fetchCategories() async {
    return await _apiService.fetchCategories();
  }

  void _retry() {
    setState(() {
      _futureCategories = _fetchCategories();
      if (_isSearching) {
        _isSearching = false;
        _searchQuery = '';
        _searchController.clear();
        _clearSearchResults();
      }
    });
  }

  void _clearSearchResults() {
    _allSearchResults.clear();
    _displayedResults.clear();
    _currentPage = 0;
    _hasMore = true;
    _isFromCache = false;
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final query = value.trim();
      setState(() {
        _searchQuery = query;
        if (_searchQuery.isNotEmpty) {
          _isSearching = true;
          _clearSearchResults();
          _searchFuture = _performSearch(query);
        } else {
          _isSearching = false;
          _searchFuture = null;
          _clearSearchResults();
        }
      });
    });
  }

  Future<List<Meal>> _performSearch(String query) async {
    final cacheService = await CacheService.getInstance();
    final cacheKey = 'search_$query';
    _isFromCache = cacheService.isCached(cacheKey);

    final results = await _apiService.searchMeals(query);
    setState(() {
      _allSearchResults = results;
      _currentPage = 0;
      _hasMore = results.length > _pageSize;
      _loadMoreResults();
    });
    return results;
  }

  void _loadMoreResults() {
    if (_isLoadingMore || !_hasMore) return;
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, _allSearchResults.length);
    if (start >= _allSearchResults.length) {
      _hasMore = false;
      return;
    }
    setState(() {
      _isLoadingMore = true;
    });
    Future.delayed(Duration.zero, () {
      setState(() {
        _displayedResults.addAll(_allSearchResults.sublist(start, end));
        _currentPage++;
        _hasMore = end < _allSearchResults.length;
        _isLoadingMore = false;
      });
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
      _searchFuture = null;
      _clearSearchResults();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Browser'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search meals...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear), onPressed: _clearSearch)
                    : null,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: _isSearching
          ? _buildSearchResults()
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _futureCategories = _fetchCategories();
                });
                await _futureCategories;
              },
              child: _buildCategoriesGrid(),
            ),
    );
  }

  Widget _buildCategoriesGrid() {
    return FutureBuilder<List<MealCategory>>(
      future: _futureCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => ShimmerLoading(
              width: double.infinity,
              height: 200,
              child: Container(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error);
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories found.'));
        }

        final categories = snapshot.data!;
        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Hero(
              tag: 'category_${category.idCategory}',
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoryScreen(categoryName: category.strCategory),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            category.strCategoryThumb,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          category.strCategory,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          category.strCategoryDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Meal>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error);
        }
        final meals = _displayedResults;
        if (meals.isEmpty && _allSearchResults.isEmpty) {
          return const Center(
              child: Text('No meals found. Try another search.'));
        }
        return Column(
          children: [
            if (_isFromCache)
              Container(
                width: double.infinity,
                color: Colors.amber[100],
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  '📦 Cached data (5 min TTL)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: meals.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == meals.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _isLoadingMore
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _loadMoreResults,
                                child: const Text('Load More'),
                              ),
                      ),
                    );
                  }
                  final meal = meals[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Hero(
                        tag: 'meal_${meal.idMeal}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            meal.strMealThumb,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.food_bank),
                          ),
                        ),
                      ),
                      title: Text(meal.strMeal,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: meal.strCategory != null
                          ? Text(meal.strCategory!)
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MealDetailScreen(mealId: meal.idMeal),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorWidget(Object? error) {
    String message = _getErrorMessage(error);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry')),
        ],
      ),
    );
  }

  String _getErrorMessage(Object? error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is ApiException) {
      return 'Server error: ${error.statusCode ?? ''} - ${error.message}';
    } else if (error is FormatException) {
      return 'Unexpected data format received.';
    } else {
      return 'An unexpected error occurred: $error';
    }
  }
}
