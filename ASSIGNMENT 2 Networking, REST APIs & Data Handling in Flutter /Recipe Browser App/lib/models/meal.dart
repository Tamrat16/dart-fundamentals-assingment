import 'ingredient.dart';

class Meal {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;
  final String? strCategory;
  final String? strArea;
  final String strInstructions;
  final String? strYoutube;
  final List<Ingredient> ingredients;

  const Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
    this.strCategory,
    this.strArea,
    required this.strInstructions,
    this.strYoutube,
    required this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = _parseIngredients(json);
    return Meal(
      idMeal: json['idMeal'] as String,
      strMeal: json['strMeal'] as String,
      strMealThumb: json['strMealThumb'] as String? ?? '',
      strCategory: json['strCategory'] as String?,
      strArea: json['strArea'] as String?,
      strInstructions: json['strInstructions'] as String? ?? '',
      strYoutube: json['strYoutube'] as String?,
      ingredients: ingredients,
    );
  }

  static List<Ingredient> _parseIngredients(Map<String, dynamic> json) {
    final ingredients = <Ingredient>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredient.trim(),
          measure: measure?.trim() ?? '',
        ));
      }
    }
    return ingredients;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strMealThumb': strMealThumb,
      'strInstructions': strInstructions,
    };
    if (strCategory != null) map['strCategory'] = strCategory;
    if (strArea != null) map['strArea'] = strArea;
    if (strYoutube != null) map['strYoutube'] = strYoutube;

    for (int i = 0; i < ingredients.length; i++) {
      map['strIngredient${i + 1}'] = ingredients[i].name;
      map['strMeasure${i + 1}'] = ingredients[i].measure;
    }
    return map;
  }

  Meal copyWith({
    String? idMeal,
    String? strMeal,
    String? strMealThumb,
    String? strCategory,
    String? strArea,
    String? strInstructions,
    String? strYoutube,
    List<Ingredient>? ingredients,
  }) {
    return Meal(
      idMeal: idMeal ?? this.idMeal,
      strMeal: strMeal ?? this.strMeal,
      strMealThumb: strMealThumb ?? this.strMealThumb,
      strCategory: strCategory ?? this.strCategory,
      strArea: strArea ?? this.strArea,
      strInstructions: strInstructions ?? this.strInstructions,
      strYoutube: strYoutube ?? this.strYoutube,
      ingredients: ingredients?.map((i) => i.copyWith()).toList() ??
          this.ingredients.map((i) => i.copyWith()).toList(),
    );
  }
}
