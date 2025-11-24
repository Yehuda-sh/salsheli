// 📄 File: lib/main.dart
// Description: Main entry point + Providers setup
//
// ✅ Recent Updates:
// - Using FirebaseProductsRepository directly (Hive removed)
// - Automatic user loading from SharedPreferences
// - Dynamic Color Support (Android 12+ Material You) 🎨

import 'package:dynamic_color/dynamic_color.dart'; // 🎨 Material You!
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 📦 Hive!
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Models
import 'models/shopping_list.dart';

// Providers
import 'providers/inventory_provider.dart';
import 'providers/locations_provider.dart';
import 'providers/product_location_provider.dart';
import 'providers/products_provider.dart';
import 'providers/receipt_provider.dart';
import 'providers/shopping_lists_provider.dart';
import 'providers/suggestions_provider.dart';
import 'providers/user_context.dart';

// Repositories
import 'repositories/firebase_inventory_repository.dart'; // 🔥 Firebase Inventory!
import 'repositories/firebase_locations_repository.dart'; // 🔥 Firebase Locations!
import 'repositories/firebase_receipt_repository.dart'; // 🔥 Firebase Receipts!
import 'repositories/firebase_shopping_lists_repository.dart'; // 🔥 Firebase Shopping Lists!
import 'repositories/firebase_user_repository.dart'; // 🔥 Firebase User!
import 'repositories/local_products_repository.dart'; // 📦 Local JSON!
import 'repositories/user_repository.dart';

// Services
import 'services/auth_service.dart'; // 🔐 Firebase Auth!
import 'services/auto_sync_initializer.dart'; // 🔄 Auto Price Sync!

// Screens
import 'screens/auth/login_screen.dart' as auth_login;
import 'screens/auth/register_screen.dart' as auth_register;
import 'screens/index_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/pantry/my_pantry_screen.dart';
import 'screens/shopping/active/active_shopping_screen.dart';
import 'screens/shopping/details/shopping_list_details_screen.dart';
import 'screens/shopping/lists/shopping_lists_screen.dart';
import 'screens/shopping/shopping_summary_screen.dart';

// Theme
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase initialization - v2.0 with duplicate app fix
  try {
    // ✅ בדיקה אם Firebase כבר אותחל (מונע duplicate app error)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Firebase initialization error: $e');
    }
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) debugPrint('Flutter Error: ${details.exception}');
  };

  // ⏸️ Wait a moment to ensure Firebase is fully ready before creating Providers
  // This prevents race condition where Providers try to access Firebase
  // (e.g., AuthService calling FirebaseAuth.instance) before initialization completes
  await Future.delayed(const Duration(milliseconds: 100));

  // 📦 Initialize Hive for local storage
  await Hive.initFlutter();

  // 📦 Create Local Products Repository
  final productsRepo = LocalProductsRepository();

  // 🔄 Initialize Auto Price Sync (runs in background)
  AutoSyncInitializer.initialize();

  runApp(
    MultiProvider(
      providers: [
        // === Auth Service === 🔐
        Provider(
          create: (_) => AuthService(),
        ),

        // === Firebase User Repository === 🔥
        Provider<UserRepository>(
          create: (_) => FirebaseUserRepository(),
        ),

        // === User Context === 👤
        ChangeNotifierProxyProvider2<AuthService, UserRepository, UserContext>(
          create: (context) => UserContext(
            repository: context.read<UserRepository>(),
            authService: context.read<AuthService>(),
          ),
          update: (context, authService, repository, previous) =>
              previous ?? UserContext(repository: repository, authService: authService),
        ),

        // === Products Provider === 🔥 Firebase
        // ⚠️ IMPORTANT: lazy: false is required! Otherwise ProductsProvider
        //    won't be created until someone needs it, causing race conditions
        //    with data loading.
        // ⚠️ skipInitialLoad: true waits for UserContext to login before loading.
        //    This prevents loading products before we have household_id.
        ChangeNotifierProxyProvider<UserContext, ProductsProvider>(
          lazy: false,
          create: (context) => ProductsProvider(
            repository: productsRepo,
            skipInitialLoad: true,
          ),
          update: (context, userContext, previous) {
            if (previous == null) {
              return ProductsProvider(repository: productsRepo);
            }

            // If user logged in - initialize and load products בצורה אסינכרונית
            if (userContext.isLoggedIn && !previous.hasInitialized) {
              // ⚡ אופטימיזציה: טעינה אסינכרונית שלא חוסמת
              Future.microtask(() => previous.initializeAndLoad());
            }

            return previous;
          },
        ),

        // === Locations Provider === 📍 Firebase!
        ChangeNotifierProxyProvider<UserContext, LocationsProvider>(
          create: (context) => LocationsProvider(
            userContext: context.read<UserContext>(),
            repository: FirebaseLocationsRepository(), // 🔥 Firebase!
          ),
          update: (context, userContext, previous) =>
              (previous ??
                    LocationsProvider(
                      userContext: userContext,
                      repository: FirebaseLocationsRepository(), // 🔥 Firebase!
                    ))
                ..updateUserContext(userContext),
        ),

        // === Shopping Lists === 🔥 Firebase!
        ChangeNotifierProxyProvider<UserContext, ShoppingListsProvider>(
          create: (context) {
            final provider = ShoppingListsProvider(
              repository: FirebaseShoppingListsRepository(), // 🔥 Firebase!
              receiptRepository: FirebaseReceiptRepository(), // 🔥 Firebase Receipts!
            );
            final userContext = context.read<UserContext>();
            provider.updateUserContext(userContext);
            return provider;
          },
          update: (context, userContext, previous) {
            final provider =
                previous ??
                ShoppingListsProvider(
                  repository: FirebaseShoppingListsRepository(), // 🔥 Firebase!
                  receiptRepository: FirebaseReceiptRepository(), // 🔥 Firebase Receipts!
                );
            provider.updateUserContext(userContext);
            return provider;
          },
        ),

        // === Inventory === 🔥 Firebase!
        ChangeNotifierProxyProvider<UserContext, InventoryProvider>(
          create: (context) => InventoryProvider(
            userContext: context.read<UserContext>(),
            repository: FirebaseInventoryRepository(), // 🔥 Firebase!
          ),
          update: (context, userContext, previous) =>
              (previous ??
                    InventoryProvider(
                      userContext: userContext,
                      repository: FirebaseInventoryRepository(), // 🔥 Firebase!
                    ))
                ..updateUserContext(userContext),
        ),

        // === Product Location Memory === 📍
        ChangeNotifierProxyProvider<UserContext, ProductLocationProvider>(
          create: (context) => ProductLocationProvider(),
          update: (context, userContext, previous) {
            previous?.updateUserContext(userContext);
            return previous ?? ProductLocationProvider();
          },
        ),

        // === Receipts === 🔥 Firebase!
        ChangeNotifierProxyProvider<UserContext, ReceiptProvider>(
          create: (context) => ReceiptProvider(
            userContext: context.read<UserContext>(),
            repository: FirebaseReceiptRepository(), // 🔥 Firebase!
          ),
          update: (context, userContext, previous) =>
              (previous ??
                    ReceiptProvider(
                      userContext: userContext,
                      repository: FirebaseReceiptRepository(), // 🔥 Firebase!
                    ))
                ..updateUserContext(userContext),
        ),

        // === Suggestions Provider ===
        // ℹ️ Note: This provider doesn't need UserContext because it only
        //    analyzes data already loaded by InventoryProvider.
        //    It doesn't access household_id directly.
        ChangeNotifierProxyProvider<InventoryProvider, SuggestionsProvider>(
          create: (context) => SuggestionsProvider(inventoryProvider: context.read<InventoryProvider>()),
          update: (context, inventoryProvider, previous) =>
              previous ?? SuggestionsProvider(inventoryProvider: inventoryProvider),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // 🎨 Material You / Dynamic Color Support!
    // Adapts app colors to user's wallpaper (Android 12+)
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {

        return MaterialApp(
          title: 'MemoZap',
          debugShowCheckedModeBanner: false,

          // 🎨 Theme with Dynamic Color or Fallback
          theme: lightDynamic != null ? AppTheme.fromDynamicColors(lightDynamic, dark: false) : AppTheme.lightTheme,

          darkTheme: darkDynamic != null ? AppTheme.fromDynamicColors(darkDynamic, dark: true) : AppTheme.darkTheme,

          locale: const Locale('he', 'IL'),
          supportedLocales: const [Locale('he', 'IL')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const IndexScreen(),
          routes: {
            '/home': (context) => const MainNavigationScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const auth_login.LoginScreen(),
            '/register': (context) => const auth_register.RegisterScreen(),

            // ❌ '/insights' route removed (insights screen deleted)
            // ❌ '/receipts' route removed (no manual receipt import)
            '/pantry': (context) => const MyPantryScreen(),
            '/inventory': (context) => const MyPantryScreen(), // alias for pantry

            '/shopping-lists': (context) => const ShoppingListsScreen(),
          },
          onGenerateRoute: (settings) {
            // shopping-summary - receives listId
            if (settings.name == '/shopping-summary') {
              final listId = settings.arguments as String?;
              if (listId == null) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Center(child: Text('List ID missing'))),
                );
              }
              return MaterialPageRoute(builder: (_) => ShoppingSummaryScreen(listId: listId));
            }

            // active-shopping - receives ShoppingList object
            if (settings.name == '/active-shopping') {
              final list = settings.arguments as ShoppingList?;
              if (list == null) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Center(child: Text('List not found'))),
                );
              }
              return MaterialPageRoute(builder: (_) => ActiveShoppingScreen(list: list));
            }

            // list-details - receives ShoppingList object
            if (settings.name == '/list-details') {
              final list = settings.arguments as ShoppingList?;
              if (list == null) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Center(child: Text('List not found'))),
                );
              }
              return MaterialPageRoute(builder: (_) => ShoppingListDetailsScreen(list: list));
            }

            // populate-list - receives ShoppingList object (alias for list-details)
            if (settings.name == '/populate-list') {
              final list = settings.arguments as ShoppingList?;
              if (list == null) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Center(child: Text('List not found'))),
                );
              }
              return MaterialPageRoute(builder: (_) => ShoppingListDetailsScreen(list: list));
            }

            return null;
          },
        );
      },
    );
  }
}
