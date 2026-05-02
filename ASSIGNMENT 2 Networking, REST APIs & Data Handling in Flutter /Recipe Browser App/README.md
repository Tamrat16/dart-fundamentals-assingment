# Recipe Browser – Flutter App

**Name:** Tamrat Arage 
**Student ID:** ATE/8888/15  
**Track:** C – Recipe Browser (TheMealDB API)

---

## 📱 Description

Recipe Browser is a Flutter application that lets users explore meal categories, browse recipes, view detailed cooking instructions, and watch YouTube tutorials. The app communicates with the free [TheMealDB](https://www.themealdb.com) REST API.

All network requests use the `http` package with `Uri.https`, 10‑second timeouts, and full error handling (`SocketException`, `TimeoutException`, `ApiException`, `FormatException`). The UI correctly manages loading, error, and data states with `FutureBuilder` and Retry buttons.

### ✨ Bonus Features Implemented
- **Search Debouncing** – Waits 500ms after the user stops typing before calling the API.
- **Pagination** – Search results are loaded 10 items at a time with a “Load More” button.
- **Local Caching** – All API responses are cached for 5 minutes using `shared_preferences`. Cached data survives app restarts, and a “Cached” badge appears when data comes from cache.

---

## 🚀 Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/recipe_browser.git
   cd recipe_browser
2. Install Flutter dependencies
Ensure you have Flutter SDK ≥3.0.0 installed. Then run:

bash
flutter pub get
Run the app
Connect a device/emulator or use Chrome:

bash
flutter run
No API key is required – TheMealDB is completely free and open.

🌐 API Endpoints Used
Endpoint	Purpose
GET /categories.php	Fetch all meal categories
GET /filter.php?c={category}	Fetch meals in a specific category
GET /lookup.php?i={mealId}	Fetch full meal details (ingredients, instructions, YouTube link)
GET /search.php?s={query}	Search meals by name (used for search feature)
All requests are built with Uri.https() and include a 10‑second timeout.

📂 Project Structure
text
lib/
├── main.dart
├── models/
│   ├── ingredient.dart
│   ├── meal_category.dart
│   └── meal.dart
├── services/
│   ├── api_exception.dart
│   ├── cache_service.dart
│   └── meal_api_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── category_screen.dart
│   └── meal_detail_screen.dart
└── widgets/
    └── shimmer_loading.dart
⚠️ Known Limitations / Bugs
Some meals may have missing images – a fallback icon is shown.

TheMealDB free API does not support server‑side pagination; pagination is simulated client‑side on search results.

Offline caching works, but an initial internet connection is required to populate the cache.

On the category screen, the API returns only basic meal information (ID, name, thumbnail). Full details are fetched when a meal is tapped.

🎥 Screen Recording
A complete demo (≥2 minutes) showing:

Initial data load from API

Search with debouncing and pagination

Navigation to detail screen

Airplane mode error handling

Retry button recovering data

The recording is submitted separately via Google Classroom.

🛠️ Built With
Flutter – UI framework

http – HTTP client

shared_preferences – Local caching

url_launcher – Open YouTube links



Instructor: Abel Tadesse
Course: Mobile Application Development – Unit 4 (Networking, REST APIs & Data Handling)
