// 📄 lib/main.dart
//
// נקודת הכניסה לאפליקציה - אתחול Firebase, Hive, ו-Providers.
// תומך ב-Dynamic Color (Material You) ו-Firebase Emulators.
//
// 🔗 Related: UserContext, AppConfig, MainNavigationScreen

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:memozap/config/app_config.dart';
import 'package:memozap/l10n/locale_manager.dart';
import 'package:memozap/firebase_options.dart';
// Models
import 'package:memozap/models/shopping_list.dart';
// Providers
import 'package:memozap/providers/inventory_provider.dart';
import 'package:memozap/providers/locations_provider.dart';
import 'package:memozap/providers/products_provider.dart';
import 'package:memozap/providers/receipt_provider.dart';
import 'package:memozap/providers/shopping_lists_provider.dart';
import 'package:memozap/providers/suggestions_provider.dart';
import 'package:memozap/providers/user_context.dart';
// Repositories
import 'package:memozap/repositories/firebase_inventory_repository.dart';
import 'package:memozap/repositories/firebase_locations_repository.dart';
import 'package:memozap/repositories/firebase_receipt_repository.dart';
import 'package:memozap/repositories/firebase_shopping_lists_repository.dart';
import 'package:memozap/repositories/firebase_user_repository.dart';
import 'package:memozap/repositories/local_products_repository.dart';
import 'package:memozap/repositories/user_repository.dart';
// Screens
import 'package:memozap/screens/auth/login_screen.dart' as auth_login;
import 'package:memozap/screens/auth/register_screen.dart' as auth_register;
import 'package:memozap/screens/index_screen.dart';
import 'package:memozap/screens/notifications/notifications_center_screen.dart';
import 'package:memozap/screens/main_navigation_screen.dart';
import 'package:memozap/screens/shopping/active/active_shopping_screen.dart';
import 'package:memozap/screens/shopping/create/create_list_screen.dart';
import 'package:memozap/screens/shopping/details/shopping_list_details_screen.dart';
import 'package:memozap/screens/shopping/shopping_summary_screen.dart';
import 'package:memozap/screens/history/shopping_history_screen.dart';
import 'package:memozap/screens/sharing/pending_invites_screen.dart';
// Services
import 'package:memozap/services/auth_service.dart';
import 'package:memozap/services/notifications_service.dart';
// Theme
import 'package:memozap/theme/app_theme.dart';
// Widgets
import 'package:memozap/widgets/dev_banner.dart';
import 'package:provider/provider.dart';

/// 🔥 חיבור ל-Firebase Emulators
Future<void> _connectToEmulators() async {
  final host = AppConfig.emulatorHost;

  FirebaseFirestore.instance.useFirestoreEmulator(host, AppConfig.firestorePort);
  await FirebaseAuth.instance.useAuthEmulator(host, AppConfig.authPort);
  await FirebaseStorage.instance.useStorageEmulator(host, AppConfig.storagePort);

  if (kDebugMode) debugPrint('✅ Connected to Firebase Emulators at $host');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }

    // 🔥 שימוש באמולטורים רק אם הוגדר ב-AppConfig (דרך dart-define)
    if (AppConfig.useEmulators) {
      await _connectToEmulators();
    }

    if (kDebugMode) {
      await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
      AppConfig.printConfig(); // הדפסת סטטוס הסביבה
    }

    if (AppConfig.isProduction) {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }
  } catch (e) {
    if (kDebugMode) debugPrint('🔴 Firebase init error: $e');
  }

  // הגדרות שגיאות Crashlytics (בייצור בלבד)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (AppConfig.isProduction) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) debugPrint('🔴 Async Error: $error\n$stack');
    if (AppConfig.isProduction) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };

  await Hive.initFlutter();

  // Repositories
  final productsRepo = LocalProductsRepository();
  final locationsRepo = FirebaseLocationsRepository();
  final shoppingListsRepo = FirebaseShoppingListsRepository();
  final receiptRepo = FirebaseReceiptRepository();
  final inventoryRepo = FirebaseInventoryRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider<NotificationsService>(create: (_) => NotificationsService(FirebaseFirestore.instance)),
        Provider<UserRepository>(create: (_) => FirebaseUserRepository()),
        ChangeNotifierProxyProvider2<AuthService, UserRepository, UserContext>(
          create: (context) =>
              UserContext(repository: context.read<UserRepository>(), authService: context.read<AuthService>()),
          update: (context, authService, repository, previous) =>
              previous ?? UserContext(repository: repository, authService: authService),
        ),
        ChangeNotifierProxyProvider<UserContext, ProductsProvider>(
          lazy: false,
          create: (context) => ProductsProvider(repository: productsRepo, skipInitialLoad: true),
          update: (context, userContext, previous) {
            final provider = previous ?? ProductsProvider(repository: productsRepo, skipInitialLoad: true);
            if (userContext.isLoggedIn && !provider.hasInitialized) {
              Future.microtask(() => provider.initializeAndLoad());
            }
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<UserContext, LocationsProvider>(
          create: (context) => LocationsProvider(userContext: context.read<UserContext>(), repository: locationsRepo),
          update: (context, userContext, previous) =>
              (previous ?? LocationsProvider(userContext: userContext, repository: locationsRepo))
                ..updateUserContext(userContext),
        ),
        ChangeNotifierProxyProvider<UserContext, ShoppingListsProvider>(
          create: (context) {
            final provider = ShoppingListsProvider(repository: shoppingListsRepo, receiptRepository: receiptRepo);
            provider.updateUserContext(context.read<UserContext>());
            return provider;
          },
          update: (context, userContext, previous) {
            final provider =
                previous ?? ShoppingListsProvider(repository: shoppingListsRepo, receiptRepository: receiptRepo);
            provider.updateUserContext(userContext);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<UserContext, ReceiptProvider>(
          create: (context) => ReceiptProvider(userContext: context.read<UserContext>(), repository: receiptRepo),
          update: (context, userContext, previous) =>
              (previous ?? ReceiptProvider(userContext: userContext, repository: receiptRepo))
                ..updateUserContext(userContext),
        ),
        ChangeNotifierProxyProvider<UserContext, InventoryProvider>(
          create: (context) => InventoryProvider(userContext: context.read<UserContext>(), repository: inventoryRepo),
          update: (context, userContext, previous) {
            final provider = previous ?? InventoryProvider(userContext: userContext, repository: inventoryRepo);
            provider.updateUserContext(userContext);
            return provider;
          },
        ),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final userContext = context.watch<UserContext>();

        return ListenableBuilder(
          listenable: LocaleManager.instance,
          builder: (context, _) => MaterialApp(
          title: 'MemoZap',
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            if (child == null) return const DevBanner();
            return Directionality(
              textDirection: LocaleManager.instance.textDirection,
              child: Stack(children: [child, const DevBanner()]),
            );
          },
          theme: lightDynamic != null ? AppTheme.fromDynamicColors(lightDynamic, dark: false) : AppTheme.lightTheme,
          darkTheme: darkDynamic != null ? AppTheme.fromDynamicColors(darkDynamic, dark: true) : AppTheme.darkTheme,
          themeMode: userContext.themeMode,
          locale: Locale(LocaleManager.instance.languageCode),
          supportedLocales: const [Locale('he', 'IL'), Locale('en', 'US')],
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
            '/create-list': (context) => const CreateListScreen(),
            '/notifications': (context) => const NotificationsCenterScreen(),
            '/receipts': (context) => const ShoppingHistoryScreen(),
            '/pending-invites': (context) => const PendingInvitesScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/shopping-summary') {
              final listId = settings.arguments as String?;
              if (listId == null) return null;
              return MaterialPageRoute(builder: (_) => ShoppingSummaryScreen(listId: listId));
            }
            if (settings.name == '/active-shopping') {
              ShoppingList? list;
              bool readOnly = false;
              if (settings.arguments is ShoppingList) {
                list = settings.arguments as ShoppingList;
              } else if (settings.arguments is Map) {
                final args = settings.arguments as Map;
                list = args['list'] as ShoppingList?;
                readOnly = args['readOnly'] as bool? ?? false;
              }
              if (list == null) return null;
              return MaterialPageRoute(
                builder: (_) => ActiveShoppingScreen(list: list!, readOnly: readOnly),
              );
            }
            if (settings.name == '/list-details' || settings.name == '/populate-list') {
              final list = settings.arguments as ShoppingList?;
              if (list == null) return null;
              return MaterialPageRoute(builder: (_) => ShoppingListDetailsScreen(list: list));
            }
            return null;
          },
        ));
      },
    );
  }
}
