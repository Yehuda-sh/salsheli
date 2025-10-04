// 📄 File: lib/main.dart
// תיאור: נקודת כניסה ראשית לאפליקציה + הגדרת Providers
//
// ✅ עדכון חדש:
// - שימוש ב-HybridProductsRepository במקום Firebase
// - אתחול Hive לפני הרצת האפליקציה
// - טעינת משתמש אוטומטית מ-SharedPreferences

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
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

// Repositories
import 'repositories/local_shopping_lists_repository.dart';
import 'repositories/inventory_repository.dart';
import 'repositories/receipt_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/local_products_repository.dart';  // 🆕
import 'repositories/hybrid_products_repository.dart';  // 🆕

// Screens
import 'screens/index_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/habits/my_habits_screen.dart';
import 'screens/insights/insights_screen.dart';

import 'screens/shopping/manage_list_screen.dart';
import 'screens/shopping/shopping_lists_screen.dart';
import 'screens/shopping/active_shopping_screen.dart';
import 'screens/shopping/shopping_list_details_screen.dart';
import 'screens/lists/populate_list_screen.dart';
import 'screens/receipts/receipt_manager_screen.dart';
import 'screens/pantry/my_pantry_screen.dart';
import 'screens/price/price_comparison_screen.dart';
import 'screens/shopping/shopping_summary_screen.dart';
// Auth screens
import 'screens/auth/login_screen.dart' as auth_login;
import 'screens/auth/register_screen.dart' as auth_register;

// Theme
import 'theme/app_theme.dart';

void main() async {
  debugPrint('\n🚀 main.dart: מתחיל אתחול אפליקציה...');
  debugPrint('═══════════════════════════════════════════');

  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('   (ממשיך בלי Firebase - נשתמש רק ב-Hive)');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  // 🆕 אתחול Hive + Hybrid Repository
  debugPrint('\n💾 מאתחל LocalProductsRepository...');
  final localRepo = LocalProductsRepository();
  
  try {
    await localRepo.init();
    debugPrint('✅ LocalProductsRepository מוכן');
    debugPrint('   📊 מוצרים קיימים: ${localRepo.totalProducts}');
  } catch (e) {
    debugPrint('❌ שגיאה באתחול LocalProductsRepository: $e');
    debugPrint('   ממשיך בכל זאת...');
  }

  // 🆕 יצירת Hybrid Repository
  debugPrint('\n🔀 יוצר HybridProductsRepository...');
  final hybridRepo = HybridProductsRepository(
    localRepo: localRepo,
  );
  debugPrint('✅ HybridProductsRepository מוכן');

  debugPrint('\n═══════════════════════════════════════════');
  debugPrint('🎯 מפעיל את האפליקציה...\n');

  runApp(
    MultiProvider(
      providers: [
        // === User Context ===
        ChangeNotifierProvider(
          create: (_) => UserContext(repository: MockUserRepository()),
        ),

        // === Products Provider === 🆕 Hybrid + ProxyProvider
        ChangeNotifierProxyProvider<UserContext, ProductsProvider>(
          lazy: false, // חייב! אחרת לא נוצר עד שמישהו צריך אותו
          create: (context) {
            debugPrint('\n🏗️ main.dart: יוצר ProductsProvider עם Hybrid...');
            final provider = ProductsProvider(
              repository: hybridRepo,
              skipInitialLoad: true, // ⚠️ לא לטעון עדיין!
            );
            debugPrint('✅ main.dart: ProductsProvider נוצר (skipInitialLoad=true)');
            return provider;
          },
          update: (context, userContext, previous) {
            debugPrint('\n🔄 ProductsProvider.update(): UserContext השתנה');
            debugPrint('   👤 User: ${userContext.user?.email ?? "guest"}');
            debugPrint('   🔐 isLoggedIn: ${userContext.isLoggedIn}');
            
            if (previous == null) {
              debugPrint('   ⚠️ previous=null, יוצר ProductsProvider חדש');
              return ProductsProvider(
                repository: hybridRepo,
              );
            }

            debugPrint('   📊 hasInitialized: ${previous.hasInitialized}');

            // אם המשתמש התחבר - אתחל ו-טען מוצרים
            if (userContext.isLoggedIn && !previous.hasInitialized) {
              debugPrint('   ✅ משתמש מחובר + לא אותחל → קורא ל-initializeAndLoad()');
              previous.initializeAndLoad();
            }

            return previous;
          },
        ),

        // === Locations Provider ===
        ChangeNotifierProvider(create: (_) => LocationsProvider()),

        // === Shopping Lists ===
        ChangeNotifierProxyProvider<UserContext, ShoppingListsProvider>(
          create: (context) {
            final provider = ShoppingListsProvider(
              repository: LocalShoppingListsRepository(),
            );
            final userContext = context.read<UserContext>();
            if (userContext.user != null) {
              provider.setCurrentUser(
                userId: userContext.user!.id,
                householdId: userContext.user!.householdId,
              );
            }
            return provider;
          },
          update: (context, userContext, previous) {
            final provider =
                previous ??
                ShoppingListsProvider(
                  repository: LocalShoppingListsRepository(),
                );
            if (userContext.user != null) {
              provider.setCurrentUser(
                userId: userContext.user!.id,
                householdId: userContext.user!.householdId,
              );
            }
            return provider;
          },
        ),
        // === Inventory ===
        ChangeNotifierProxyProvider<UserContext, InventoryProvider>(
          create: (context) => InventoryProvider(
            userContext: context.read<UserContext>(),
            repository: MockInventoryRepository(),
          ),
          update: (context, userContext, previous) =>
              (previous ??
                    InventoryProvider(
                      userContext: userContext,
                      repository: MockInventoryRepository(),
                    ))
                ..updateUserContext(userContext),
        ),

        // === Receipts ===
        ChangeNotifierProxyProvider<UserContext, ReceiptProvider>(
          create: (context) => ReceiptProvider(
            userContext: context.read<UserContext>(),
            repository: MockReceiptRepository(),
          ),
          update: (context, userContext, previous) =>
              (previous ??
                    ReceiptProvider(
                      userContext: userContext,
                      repository: MockReceiptRepository(),
                    ))
                ..updateUserContext(userContext),
        ),

        // === Suggestions Provider ===
        ChangeNotifierProxyProvider3<
          UserContext,
          InventoryProvider,
          ShoppingListsProvider,
          SuggestionsProvider
        >(
          create: (context) => SuggestionsProvider(
            inventoryProvider: context.read<InventoryProvider>(),
            listsProvider: context.read<ShoppingListsProvider>(),
            userContext: context.read<UserContext>(),
          ),
          update:
              (
                context,
                userContext,
                inventoryProvider,
                listsProvider,
                previous,
              ) =>
                  previous ??
                  SuggestionsProvider(
                    inventoryProvider: inventoryProvider,
                    listsProvider: listsProvider,
                    userContext: userContext,
                  ),
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
  void initState() {
    super.initState();
    _loadSavedUser();
  }

  /// 👤 טעינת משתמש שמור אחרי שכל ה-Providers נבנו
  Future<void> _loadSavedUser() async {
    debugPrint('👤 MyApp: בודק אם יש משתמש שמור...');
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');

    if (savedUserId != null && mounted) {
      debugPrint('✅ MyApp: נמצא userId שמור: $savedUserId');
      final userContext = context.read<UserContext>();
      await userContext.loadUser(savedUserId);
      debugPrint('✅ MyApp: משתמש נטען בהצלחה');
    } else {
      debugPrint('⚠️ MyApp: אין משתמש שמור');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'סל שלי',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
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
        '/receipts': (context) => const ReceiptManagerScreen(),
        '/pantry': (context) => const MyPantryScreen(),
        '/inventory': (context) => const MyPantryScreen(), // alias for pantry
        '/price-comparison': (context) => const PriceComparisonScreen(),
        '/price-compare': (context) => const PriceComparisonScreen(), // alias
        '/shopping-lists': (context) => const ShoppingListsScreen(),
      },
      onGenerateRoute: (settings) {
        // shopping-summary - מקבל listId
        if (settings.name == '/shopping-summary') {
          final listId = settings.arguments as String?;
          if (listId == null) {
            return MaterialPageRoute(
              builder: (_) =>
                  Scaffold(body: Center(child: Text('מזהה רשימה חסר'))),
            );
          }
          return MaterialPageRoute(
            builder: (_) => ShoppingSummaryScreen(listId: listId),
          );
        }
        // manage-list - צריך רק list (ShoppingList)
        if (settings.name == '/manage-list') {
          final args = settings.arguments as Map<String, dynamic>?;
          final list = args?['list'] as ShoppingList?;
          if (list == null) {
            return MaterialPageRoute(
              builder: (_) =>
                  Scaffold(body: Center(child: Text('רשימה לא נמצאה'))),
            );
          }
          return MaterialPageRoute(
            builder: (_) =>
                ManageListScreen(listName: list.name, listId: list.id),
          );
        }

        // active-shopping - מקבל listName ו-listId
        if (settings.name == '/active-shopping') {
          final list = settings.arguments as ShoppingList?;
          if (list == null) {
            return MaterialPageRoute(
              builder: (_) =>
                  Scaffold(body: Center(child: Text('רשימה לא נמצאה'))),
            );
          }
          return MaterialPageRoute(
            builder: (_) =>
                ActiveShoppingScreen(listName: list.name, listId: list.id),
          );
        }

        // list-details - מקבל ShoppingList object
        if (settings.name == '/list-details') {
          final list = settings.arguments as ShoppingList?;
          if (list == null) {
            return MaterialPageRoute(
              builder: (_) =>
                  Scaffold(body: Center(child: Text('רשימה לא נמצאה'))),
            );
          }
          return MaterialPageRoute(
            builder: (_) => ShoppingListDetailsScreen(list: list),
          );
        }

        // populate-list - מקבל ShoppingList object
        if (settings.name == '/populate-list') {
          final list = settings.arguments as ShoppingList?;
          if (list == null) {
            return MaterialPageRoute(
              builder: (_) =>
                  Scaffold(body: Center(child: Text('רשימה לא נמצאה'))),
            );
          }
          return MaterialPageRoute(
            builder: (_) => PopulateListScreen(list: list),
          );
        }

        return null;
      },
    );
  }
}
