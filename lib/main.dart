// 📄 File: lib/main.dart
// Description: Main entry point + Providers setup
//
// ✅ Recent Updates:
// - Using FirebaseProductsRepository directly (Hive removed)
// - Automatic user loading from SharedPreferences
// - Dynamic Color Support (Android 12+ Material You) 🎨

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dynamic_color/dynamic_color.dart';  // 🎨 Material You!
import 'firebase_options.dart';

// Models
import 'models/shopping_list.dart';

// Providers
import 'providers/user_context.dart';
import 'providers/shopping_lists_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/receipt_provider.dart';
import 'providers/products_provider.dart';
import 'providers/suggestions_provider.dart';
import 'providers/locations_provider.dart';
import 'providers/habits_provider.dart';
import 'providers/templates_provider.dart';
import 'providers/product_location_provider.dart';

// Repositories
import 'repositories/firebase_shopping_lists_repository.dart';  // 🔥 Firebase Shopping Lists!
import 'repositories/user_repository.dart';
import 'repositories/firebase_user_repository.dart';  // 🔥 Firebase User!
import 'repositories/firebase_receipt_repository.dart';  // 🔥 Firebase Receipts!
import 'repositories/firebase_inventory_repository.dart';  // 🔥 Firebase Inventory!
import 'repositories/firebase_products_repository.dart';  // 🔥 Firebase!
import 'repositories/firebase_habits_repository.dart';  // 🔥 Firebase Habits!
import 'repositories/firebase_templates_repository.dart';  // 🔥 Firebase Templates!
import 'repositories/firebase_locations_repository.dart';  // 🔥 Firebase Locations!

// Services
import 'services/auth_service.dart';  // 🔐 Firebase Auth!

// Screens
import 'screens/index_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/habits/my_habits_screen.dart';
import 'screens/insights/insights_screen.dart';

import 'screens/shopping/shopping_lists_screen.dart';
import 'screens/shopping/active_shopping_screen.dart';
import 'screens/shopping/shopping_list_details_screen.dart';
import 'screens/lists/populate_list_screen.dart';
import 'screens/lists/templates_screen.dart';  // 📋 Templates!
// ❌ Receipt Import Screen removed (no more manual receipt scanning)
import 'screens/pantry/my_pantry_screen.dart';
import 'screens/price/price_comparison_screen.dart';
import 'screens/shopping/shopping_summary_screen.dart';
// Auth screens
import 'screens/auth/login_screen.dart' as auth_login;
import 'screens/auth/register_screen.dart' as auth_register;

// Theme
import 'theme/app_theme.dart';

void main() async {
  if (kDebugMode) {
    debugPrint('\n🚀 main.dart: Starting app initialization...');
    debugPrint('═══════════════════════════════════════════');
  }

  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase initialization - v2.0 with duplicate app fix
  try {
    if (kDebugMode) debugPrint('\n🔍 Checking Firebase apps... count: ${Firebase.apps.length}');
    
    // ✅ בדיקה אם Firebase כבר אותחל (מונע duplicate app error)
    if (Firebase.apps.isEmpty) {
      if (kDebugMode) debugPrint('   ➡️ No apps found, initializing...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (kDebugMode) debugPrint('   ✅ Firebase initialized successfully!');
    } else {
      if (kDebugMode) debugPrint('   ℹ️ Firebase already initialized (${Firebase.apps.length} apps)');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('   ❌ Firebase initialization error: $e');
      debugPrint('   (App will continue without Firebase)');
    }
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) debugPrint('Flutter Error: ${details.exception}');
  };

  // ⏸️ Wait a moment to ensure Firebase is fully ready before creating Providers
  // This prevents race condition where Providers try to access Firebase
  // (e.g., AuthService calling FirebaseAuth.instance) before initialization completes
  await Future.delayed(Duration(milliseconds: 100));
  if (kDebugMode) debugPrint('⏳ Waited for Firebase stabilization');

  // 🔥 Create Firebase Repository
  if (kDebugMode) {
    debugPrint('\n🔥 Creating FirebaseProductsRepository...');
  }
  final firebaseRepo = FirebaseProductsRepository();
  if (kDebugMode) {
    debugPrint('✅ FirebaseProductsRepository ready');
    debugPrint('\n═══════════════════════════════════════════');
    debugPrint('🎯 Launching app...\n');
  }

  runApp(
    MultiProvider(
      providers: [
        // === Auth Service === 🔐
        Provider(
          create: (_) {
            if (kDebugMode) debugPrint('🔐 main.dart: Creating AuthService');
            return AuthService();
          },
        ),

        // === Firebase User Repository === 🔥
        Provider<UserRepository>(
          create: (_) {
            if (kDebugMode) debugPrint('🔥 main.dart: Creating FirebaseUserRepository');
            return FirebaseUserRepository();
          },
        ),

        // === User Context === 👤
        ChangeNotifierProxyProvider2<AuthService, UserRepository, UserContext>(
          create: (context) {
            if (kDebugMode) debugPrint('👤 main.dart: Creating UserContext with Firebase');
            return UserContext(
              repository: context.read<UserRepository>(),
              authService: context.read<AuthService>(),
            );
          },
          update: (context, authService, repository, previous) {
            if (kDebugMode) debugPrint('🔄 main.dart: Updating UserContext');
            return previous ?? UserContext(
              repository: repository,
              authService: authService,
            );
          },
        ),

        // === Products Provider === 🔥 Firebase
        // ⚠️ IMPORTANT: lazy: false is required! Otherwise ProductsProvider
        //    won't be created until someone needs it, causing race conditions
        //    with data loading.
        // ⚠️ skipInitialLoad: true waits for UserContext to login before loading.
        //    This prevents loading products before we have household_id.
        ChangeNotifierProxyProvider<UserContext, ProductsProvider>(
          lazy: false,
          create: (context) {
            if (kDebugMode) {
              debugPrint('\n🏗️ main.dart: Creating ProductsProvider with Firebase...');
            }
            final provider = ProductsProvider(
              repository: firebaseRepo,
              skipInitialLoad: true,
            );
            if (kDebugMode) {
              debugPrint('✅ main.dart: ProductsProvider created (skipInitialLoad=true)');
            }
            return provider;
          },
          update: (context, userContext, previous) {
            if (kDebugMode) {
              debugPrint('\n🔄 ProductsProvider.update(): UserContext changed');
              debugPrint('   👤 User: ${userContext.user?.email ?? "guest"}');
              debugPrint('   🔐 isLoggedIn: ${userContext.isLoggedIn}');
            }
            
            if (previous == null) {
              if (kDebugMode) debugPrint('   ⚠️ previous=null, creating new ProductsProvider');
              return ProductsProvider(
                repository: firebaseRepo,
              );
            }

            if (kDebugMode) debugPrint('   📊 hasInitialized: ${previous.hasInitialized}');

            // If user logged in - initialize and load products בצורה אסינכרונית
            if (userContext.isLoggedIn && !previous.hasInitialized) {
              if (kDebugMode) debugPrint('   ✅ User logged in + not initialized → calling initializeAndLoad()');
              // ⚡ אופטימיזציה: טעינה אסינכרונית שלא חוסמת
              Future.microtask(() => previous.initializeAndLoad());
            }

            return previous;
          },
        ),

        // === Locations Provider === 📍 Firebase!
        ChangeNotifierProxyProvider<UserContext, LocationsProvider>(
          create: (context) {
            if (kDebugMode) debugPrint('📍 main.dart: Creating LocationsProvider with Firebase');
            return LocationsProvider(
              userContext: context.read<UserContext>(),
              repository: FirebaseLocationsRepository(),  // 🔥 Firebase!
            );
          },
          update: (context, userContext, previous) {
            if (kDebugMode) debugPrint('🔄 main.dart: Updating LocationsProvider');
            return (previous ??
                    LocationsProvider(
                      userContext: userContext,
                      repository: FirebaseLocationsRepository(),  // 🔥 Firebase!
                    ))
                ..updateUserContext(userContext);
          },
        ),

        // === Shopping Lists === 🔥 Firebase!
        ChangeNotifierProxyProvider<UserContext, ShoppingListsProvider>(
          create: (context) {
            if (kDebugMode) debugPrint('📋 main.dart: Creating ShoppingListsProvider with Firebase');
            final provider = ShoppingListsProvider(
              repository: FirebaseShoppingListsRepository(),  // 🔥 Firebase!
              receiptRepository: FirebaseReceiptRepository(),  // 🔥 Firebase Receipts!
            );
            final userContext = context.read<UserContext>();
            provider.updateUserContext(userContext);
            return provider;
          },
          update: (context, userContext, previous) {
            if (kDebugMode) debugPrint('🔄 main.dart: Updating ShoppingListsProvider');
            final provider =
                previous ??
                ShoppingListsProvider(
                  repository: FirebaseShoppingListsRepository(),  // 🔥 Firebase!
                  receiptRepository: FirebaseReceiptRepository(),  // 🔥 Firebase Receipts!
                );
            provider.updateUserContext(userContext);
            return provider;
          },
        ),

        // === Inventory === 🔥 Firebase!
        ChangeNotifierProxyProvider<UserContext, InventoryProvider>(
          create: (context) {
            if (kDebugMode) debugPrint('📦 main.dart: Creating InventoryProvider with Firebase');
            return InventoryProvider(
              userContext: context.read<UserContext>(),
              repository: FirebaseInventoryRepository(),  // 🔥 Firebase!
            );
          },
          update: (context, userContext, previous) {
            if (kDebugMode) debugPrint('🔄 main.dart: Updating InventoryProvider');
            return (previous ??
                    InventoryProvider(
                      userContext: userContext,
                      repository: FirebaseInventoryRepository(),  // 🔥 Firebase!
                    ))
                ..updateUserContext(userContext);
          },
        ),

        // === Product Location Memory === 📍
        ChangeNotifierProxyProvider<UserContext, ProductLocationProvider>(
          create: (context) {
            if (kDebugMode) debugPrint('📍 main.dart: Creating ProductLocationProvider');
            return ProductLocationProvider();
          },
          update: (context, userContext, previous) {
            if (kDebugMode) debugPrint('🔄 main.dart: Updating ProductLocationProvider');
            previous?.updateUserContext(userContext);
            return previous ?? ProductLocationProvider();
          },
        ),

        // === Receipts === 🔥 Firebase!
        ChangeNotifierProxyProvider<UserContext, ReceiptProvider>(
          create: (context) {
            if (kDebugMode) debugPrint('📄 main.dart: Creating ReceiptProvider with Firebase');
            return ReceiptProvider(
              userContext: context.read<UserContext>(),
              repository: FirebaseReceiptRepository(),  // 🔥 Firebase!
            );
          },
          update: (context, userContext, previous) {
            if (kDebugMode) debugPrint('🔄 main.dart: Updating ReceiptProvider');
            return (previous ??
                    ReceiptProvider(
                      userContext: userContext,
                      repository: FirebaseReceiptRepository(),  // 🔥 Firebase!
                    ))
                ..updateUserContext(userContext);
          },
        ),

        // === Suggestions Provider ===
        // ℹ️ Note: This provider doesn't need UserContext because it only
        //    analyzes data already loaded by InventoryProvider.
        //    It doesn't access household_id directly.
        ChangeNotifierProxyProvider<
          InventoryProvider,
          SuggestionsProvider
        >(
          create: (context) => SuggestionsProvider(
            inventoryProvider: context.read<InventoryProvider>(),
          ),
          update: (context, inventoryProvider, previous) =>
              previous ??
              SuggestionsProvider(
                inventoryProvider: inventoryProvider,
              ),
        ),

        // === Habits Provider === 🧠 Firebase!
        ChangeNotifierProxyProvider<UserContext, HabitsProvider>(
          create: (context) {
            if (kDebugMode) debugPrint('🧠 main.dart: Creating HabitsProvider with Firebase');
            final provider = HabitsProvider(
              FirebaseHabitsRepository(),  // 🔥 Firebase!
            );
            final userContext = context.read<UserContext>();
            provider.updateUserContext(userContext);
            return provider;
          },
          update: (context, userContext, previous) {
            if (kDebugMode) debugPrint('🔄 main.dart: Updating HabitsProvider');
            final provider =
                previous ??
                HabitsProvider(
                  FirebaseHabitsRepository(),  // 🔥 Firebase!
                );
            provider.updateUserContext(userContext);
            return provider;
          },
        ),

        // === Templates Provider === 📋 Firebase!
        ChangeNotifierProxyProvider<UserContext, TemplatesProvider>(
          create: (context) {
            if (kDebugMode) debugPrint('📋 main.dart: Creating TemplatesProvider with Firebase');
            final provider = TemplatesProvider(
              repository: FirebaseTemplatesRepository(),  // 🔥 Firebase!
            );
            final userContext = context.read<UserContext>();
            provider.updateUserContext(userContext);
            return provider;
          },
          update: (context, userContext, previous) {
            if (kDebugMode) debugPrint('🔄 main.dart: Updating TemplatesProvider');
            final provider =
                previous ??
                TemplatesProvider(
                  repository: FirebaseTemplatesRepository(),  // 🔥 Firebase!
                );
            provider.updateUserContext(userContext);
            return provider;
          },
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
        if (kDebugMode) {
          debugPrint('\n🎨 DynamicColorBuilder:');
          debugPrint('   📱 lightDynamic: ${lightDynamic != null ? "✅ Available" : "❌ Not available"}');
          debugPrint('   🌙 darkDynamic: ${darkDynamic != null ? "✅ Available" : "❌ Not available"}');
          
          if (lightDynamic != null || darkDynamic != null) {
            debugPrint('   🎉 Material You detected! Using dynamic colors');
          } else {
            debugPrint('   ℹ️ Dynamic Color not available, using standard colors');
          }
        }

        return MaterialApp(
          title: 'MemoZap',
          debugShowCheckedModeBanner: false,
          
          // 🎨 Theme with Dynamic Color or Fallback
          theme: lightDynamic != null
              ? AppTheme.fromDynamicColors(lightDynamic, dark: false)
              : AppTheme.lightTheme,
          
          darkTheme: darkDynamic != null
              ? AppTheme.fromDynamicColors(darkDynamic, dark: true)
              : AppTheme.darkTheme,
          
          themeMode: ThemeMode.system,
          locale: const Locale('he', 'IL'),
          supportedLocales: const [Locale('he', 'IL')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const IndexScreen(),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/login': (context) => const auth_login.LoginScreen(),
            '/register': (context) => const auth_register.RegisterScreen(),
            '/habits': (context) => const MyHabitsScreen(),
            '/insights': (context) => const InsightsScreen(),
            // ❌ '/receipts' route removed (no manual receipt import)
            '/pantry': (context) => const MyPantryScreen(),
            '/inventory': (context) => const MyPantryScreen(), // alias for pantry
            '/price-comparison': (context) => const PriceComparisonScreen(),
            '/price-compare': (context) => const PriceComparisonScreen(), // alias
            '/shopping-lists': (context) => const ShoppingListsScreen(),
            '/templates': (context) => const TemplatesScreen(),  // 📋 Templates!
          },
          onGenerateRoute: (settings) {
            // shopping-summary - receives listId
            if (settings.name == '/shopping-summary') {
              final listId = settings.arguments as String?;
              if (listId == null) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(child: Text('List ID missing')),
                  ),
                );
              }
              return MaterialPageRoute(
                builder: (_) => ShoppingSummaryScreen(listId: listId),
              );
            }

            // active-shopping - receives ShoppingList object
            if (settings.name == '/active-shopping') {
              final list = settings.arguments as ShoppingList?;
              if (list == null) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(child: Text('List not found')),
                  ),
                );
              }
              return MaterialPageRoute(
                builder: (_) => ActiveShoppingScreen(list: list),
              );
            }

            // list-details - receives ShoppingList object
            if (settings.name == '/list-details') {
              final list = settings.arguments as ShoppingList?;
              if (list == null) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(child: Text('List not found')),
                  ),
                );
              }
              return MaterialPageRoute(
                builder: (_) => ShoppingListDetailsScreen(list: list),
              );
            }

            // populate-list - receives ShoppingList object
            if (settings.name == '/populate-list') {
              final list = settings.arguments as ShoppingList?;
              if (list == null) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(child: Text('List not found')),
                  ),
                );
              }
              return MaterialPageRoute(
                builder: (_) => PopulateListScreen(list: list),
              );
            }

            return null;
          },
        );
      },
    );
  }
}
