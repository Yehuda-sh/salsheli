// 📄 File: lib/main.dart
// Description: Main entry point + Providers setup
//
// ✅ Recent Updates:
// - Using FirebaseProductsRepository directly
// - Automatic user loading from SharedPreferences
// - Dynamic Color Support (Android 12+ Material You) 🎨
// - Hive for local storage
// - Firebase Emulators support for development 🔥
// - Async error handling with PlatformDispatcher 🛡️

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_color/dynamic_color.dart'; // 🎨 Material You!
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 📦 Hive!
import 'package:memozap/config/app_config.dart'; // ⚙️ App Config!
import 'package:memozap/firebase_options.dart';
// Models
import 'package:memozap/models/shopping_list.dart';
// Providers
import 'package:memozap/providers/groups_provider.dart';
import 'package:memozap/providers/inventory_provider.dart';
import 'package:memozap/providers/locations_provider.dart';
import 'package:memozap/providers/pending_invites_provider.dart';
import 'package:memozap/providers/product_location_provider.dart';
import 'package:memozap/providers/products_provider.dart';
import 'package:memozap/providers/receipt_provider.dart';
import 'package:memozap/providers/shopping_lists_provider.dart';
import 'package:memozap/providers/suggestions_provider.dart';
import 'package:memozap/providers/user_context.dart';
// Repositories
import 'package:memozap/repositories/firebase_group_repository.dart'; // 🔥 Firebase Groups!
import 'package:memozap/repositories/firebase_inventory_repository.dart'; // 🔥 Firebase Inventory!
import 'package:memozap/repositories/firebase_locations_repository.dart'; // 🔥 Firebase Locations!
import 'package:memozap/repositories/firebase_receipt_repository.dart'; // 🔥 Firebase Receipts!
import 'package:memozap/repositories/firebase_shopping_lists_repository.dart'; // 🔥 Firebase Shopping Lists!
import 'package:memozap/repositories/firebase_user_repository.dart'; // 🔥 Firebase User!
import 'package:memozap/repositories/local_products_repository.dart'; // 📦 Local JSON!
import 'package:memozap/repositories/user_repository.dart';
// Screens
import 'package:memozap/screens/auth/login_screen.dart' as auth_login;
import 'package:memozap/screens/auth/register_screen.dart' as auth_register;
import 'package:memozap/screens/groups/create_group_screen.dart';
import 'package:memozap/screens/groups/group_details_screen.dart';
import 'package:memozap/screens/groups/pending_group_invites_screen.dart';
import 'package:memozap/screens/index_screen.dart';
import 'package:memozap/screens/main_navigation_screen.dart';
import 'package:memozap/screens/pantry/my_pantry_screen.dart';
import 'package:memozap/screens/sharing/pending_invites_screen.dart';
import 'package:memozap/screens/shopping/active/active_shopping_screen.dart';
import 'package:memozap/screens/shopping/create/create_list_screen.dart';
import 'package:memozap/screens/shopping/details/shopping_list_details_screen.dart';
import 'package:memozap/screens/shopping/lists/shopping_lists_screen.dart';
import 'package:memozap/screens/shopping/shopping_summary_screen.dart';
// Services
import 'package:memozap/services/auth_service.dart'; // 🔐 Firebase Auth!
// Theme
import 'package:memozap/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// 🔥 חיבור ל-Firebase Emulators (לפיתוח מקומי)
Future<void> _connectToEmulators() async {
  final host = AppConfig.emulatorHost;

  // Firestore Emulator
  FirebaseFirestore.instance.useFirestoreEmulator(host, AppConfig.firestorePort);
  debugPrint('🔥 Connected to Firestore Emulator at $host:${AppConfig.firestorePort}');

  // Auth Emulator
  await FirebaseAuth.instance.useAuthEmulator(host, AppConfig.authPort);
  debugPrint('🔐 Connected to Auth Emulator at $host:${AppConfig.authPort}');

  // Storage Emulator
  await FirebaseStorage.instance.useStorageEmulator(host, AppConfig.storagePort);
  debugPrint('📦 Connected to Storage Emulator at $host:${AppConfig.storagePort}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase initialization - v2.0 with duplicate app fix
  try {
    // ✅ בדיקה אם Firebase כבר אותחל (מונע duplicate app error)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }

    // 🔥 חיבור ל-Firebase Emulators במצב פיתוח
    if (AppConfig.useEmulators) {
      await _connectToEmulators();
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Firebase initialization error: $e');
    }
  }

  // 📊 הדפסת הגדרות (רק ב-debug)
  if (kDebugMode) {
    AppConfig.printConfig();
  }

  // 🛡️ תפיסת שגיאות Flutter (UI)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) debugPrint('🔴 Flutter Error: ${details.exception}');
  };

  // 🛡️ תפיסת שגיאות אסינכרוניות (Futures, Isolates)
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) debugPrint('🔴 Async Error: $error\n$stack');
    return true; // מונע קריסה שקטה
  };

  // 📦 Initialize Hive for local storage
  await Hive.initFlutter();

  // 📦 Create Repositories (single instance each)
  final productsRepo = LocalProductsRepository();
  final locationsRepo = FirebaseLocationsRepository();
  final shoppingListsRepo = FirebaseShoppingListsRepository();
  final receiptRepo = FirebaseReceiptRepository();
  final inventoryRepo = FirebaseInventoryRepository();

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
            repository: locationsRepo,
          ),
          update: (context, userContext, previous) =>
              (previous ??
                    LocationsProvider(
                      userContext: userContext,
                      repository: locationsRepo,
                    ))
                ..updateUserContext(userContext),
        ),

        // === Shopping Lists === 🔥 Firebase!
        ChangeNotifierProxyProvider<UserContext, ShoppingListsProvider>(
          create: (context) {
            final provider = ShoppingListsProvider(
              repository: shoppingListsRepo,
              receiptRepository: receiptRepo,
            );
            final userContext = context.read<UserContext>();
            provider.updateUserContext(userContext);
            return provider;
          },
          update: (context, userContext, previous) {
            final provider =
                previous ??
                ShoppingListsProvider(
                  repository: shoppingListsRepo,
                  receiptRepository: receiptRepo,
                );
            provider.updateUserContext(userContext);
            return provider;
          },
        ),

        // === Inventory === 🔥 Firebase!
        ChangeNotifierProxyProvider<UserContext, InventoryProvider>(
          create: (context) => InventoryProvider(
            userContext: context.read<UserContext>(),
            repository: inventoryRepo,
          ),
          update: (context, userContext, previous) =>
              (previous ??
                    InventoryProvider(
                      userContext: userContext,
                      repository: inventoryRepo,
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
            repository: receiptRepo,
          ),
          update: (context, userContext, previous) =>
              (previous ??
                    ReceiptProvider(
                      userContext: userContext,
                      repository: receiptRepo,
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

        // === Pending Invites Provider === 📨 Group Invitations!
        // ⚠️ חייב להיות לפני GroupsProvider כי הוא משתף את ה-repository
        ChangeNotifierProvider<PendingInvitesProvider>(
          create: (_) => PendingInvitesProvider(),
        ),

        // === Groups Provider === 👥 Firebase Groups!
        ChangeNotifierProxyProvider2<UserContext, PendingInvitesProvider, GroupsProvider>(
          create: (context) => GroupsProvider(
            repository: FirebaseGroupRepository(),
            inviteRepository: context.read<PendingInvitesProvider>().repository,
          ),
          update: (context, userContext, pendingInvites, previous) {
            if (previous != null) {
              previous.updateUserContext(userContext);
            }
            return previous ?? GroupsProvider(
              repository: FirebaseGroupRepository(),
              inviteRepository: pendingInvites.repository,
            );
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// 🚨 מסך שגיאת ניתוב - עם AppBar לחזרה
class _RouteErrorScreen extends StatelessWidget {
  final String message;
  final String? routeName;

  const _RouteErrorScreen({
    required this.message,
    this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('שגיאה'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: cs.error,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (routeName != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Route: $routeName',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false),
                icon: const Icon(Icons.home),
                label: const Text('חזור לדף הבית'),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
            '/login': (context) => const auth_login.LoginScreen(),
            '/register': (context) => const auth_register.RegisterScreen(),

            '/pantry': (context) => const MyPantryScreen(),
            '/inventory': (context) => const MyPantryScreen(), // alias for pantry

            '/shopping-lists': (context) => const ShoppingListsScreen(),
            '/create-list': (context) => const CreateListScreen(),

            '/pending-invites': (context) => const PendingInvitesScreen(),
            '/pending-group-invites': (context) => const PendingGroupInvitesScreen(),
            '/create-group': (context) => const CreateGroupScreen(),
          },
          onGenerateRoute: (settings) {
            // shopping-summary - receives listId
            if (settings.name == '/shopping-summary') {
              final listId = settings.arguments as String?;
              if (listId == null) {
                return MaterialPageRoute(
                  builder: (_) => _RouteErrorScreen(
                    message: 'מזהה רשימה חסר',
                    routeName: settings.name,
                  ),
                );
              }
              return MaterialPageRoute(builder: (_) => ShoppingSummaryScreen(listId: listId));
            }

            // active-shopping - receives ShoppingList object
            if (settings.name == '/active-shopping') {
              final list = settings.arguments as ShoppingList?;
              if (list == null) {
                return MaterialPageRoute(
                  builder: (_) => _RouteErrorScreen(
                    message: 'רשימת קניות לא נמצאה',
                    routeName: settings.name,
                  ),
                );
              }
              return MaterialPageRoute(builder: (_) => ActiveShoppingScreen(list: list));
            }

            // list-details - receives ShoppingList object
            if (settings.name == '/list-details') {
              final list = settings.arguments as ShoppingList?;
              if (list == null) {
                return MaterialPageRoute(
                  builder: (_) => _RouteErrorScreen(
                    message: 'רשימת קניות לא נמצאה',
                    routeName: settings.name,
                  ),
                );
              }
              return MaterialPageRoute(builder: (_) => ShoppingListDetailsScreen(list: list));
            }

            // populate-list - receives ShoppingList object (alias for list-details)
            if (settings.name == '/populate-list') {
              final list = settings.arguments as ShoppingList?;
              if (list == null) {
                return MaterialPageRoute(
                  builder: (_) => _RouteErrorScreen(
                    message: 'רשימת קניות לא נמצאה',
                    routeName: settings.name,
                  ),
                );
              }
              return MaterialPageRoute(builder: (_) => ShoppingListDetailsScreen(list: list));
            }

            // group-details - receives groupId
            if (settings.name == '/group-details') {
              final groupId = settings.arguments as String?;
              if (groupId == null) {
                return MaterialPageRoute(
                  builder: (_) => _RouteErrorScreen(
                    message: 'מזהה קבוצה חסר',
                    routeName: settings.name,
                  ),
                );
              }
              return MaterialPageRoute(builder: (_) => GroupDetailsScreen(groupId: groupId));
            }

            return null;
          },
        );
      },
    );
  }
}
