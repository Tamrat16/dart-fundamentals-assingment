import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:recipe_browser/services/meal_api_service.dart';
import 'package:recipe_browser/services/api_exception.dart';
import 'package:recipe_browser/models/meal.dart';
import 'meal_detail_screen.dart';
import '../widgets/shimmer_loading.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  const CategoryScreen({super.key, required this.categoryName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Meal>> _futureMeals;
  final MealApiService _apiService = MealApiService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _futureMeals = _fetchMeals();
  }

  Future<List<Meal>> _fetchMeals() async {
    return await _apiService.fetchMealsByCategory(widget.categoryName);
  }

  void _retry() {
    setState(() {
      _futureMeals = _fetchMeals();
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _futureMeals = _fetchMeals();
          });
          await _futureMeals;
        },
        child: FutureBuilder<List<Meal>>(
          future: _futureMeals,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 6,
                itemBuilder: (_, __) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ShimmerLoading(
                    width: double.infinity,
                    height: 80,
                    child: Container(),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error);
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('No meals found in this category.'));
            }

            final meals = snapshot.data!;
            return ListView.builder(
              controller: _scrollController,
              itemCount: meals.length,
              itemBuilder: (context, index) {
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
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MealDetailScreen(mealId: meal.idMeal),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        child: const Icon(Icons.arrow_upward),
      ),
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
