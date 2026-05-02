# Recipe Browser – Flutter App (Track C)

**Name:** Tamrat Arage  
**Student ID:** ATE/8888/15  
**Track:** Recipe Browser (TheMealDB API)

## Description
A Flutter application that browses meal categories, lists meals in each category, and displays full recipe details including ingredients, instructions, and a YouTube link. The app communicates with TheMealDB public REST API.

## Bonus Features Implemented
- ✅ Search debouncing (500ms delay, +5 marks)
- ✅ Pagination for search results (load 10 items at a time, +5 marks)
- ✅ Local caching with 5-minute TTL using shared_preferences (+5 marks)
- ✅ "Cached" badge appears when data is served from cache

## Setup Instructions
1. Clone the repository.
2. Ensure Flutter SDK >=3.0.0 is installed.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` on a device/emulator.

No API key required.

## API Endpoints Used
- GET /categories.php – fetch all meal categories.
- GET /filter.php?c={category} – fetch meals in a specific category.
- GET /lookup.php?i={mealId} – fetch full details of a meal.
- GET /search.php?s={query} – search meals by name (used for search).

## Known Limitations / Bugs
- Some meals may have missing images; a fallback icon is shown.
- TheMealDB free API does not support pagination; pagination is simulated client-side on search results.
- Offline caching works but requires an initial online fetch.

## Build & Run
```bash
flutter clean
flutter pub get
flutter run