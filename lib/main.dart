import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/database_service.dart';
import 'core/services/api_service.dart';
import 'core/services/sync_service.dart';
import 'data/repositories/isar_expense_repository.dart';
import 'data/repositories/isar_ticket_repository.dart';
import 'data/repositories/isar_member_repository.dart';
import 'data/repositories/isar_booking_repository.dart';
import 'data/repositories/isar_amenity_repository.dart';
import 'data/repositories/isar_announcement_repository.dart';
import 'data/repositories/isar_payment_repository.dart';
import 'data/repositories/isar_message_repository.dart';
import 'data/repositories/isar_group_member_repository.dart';
import 'data/repositories/isar_group_repository.dart';
import 'domain/repositories/expense_repository.dart';
import 'domain/repositories/ticket_repository.dart';
import 'domain/repositories/member_repository.dart';
import 'domain/repositories/booking_repository.dart';
import 'domain/repositories/amenity_repository.dart';
import 'domain/repositories/announcement_repository.dart';
import 'domain/repositories/payment_repository.dart';
import 'domain/repositories/message_repository.dart';
import 'domain/repositories/group_member_repository.dart';
import 'domain/repositories/group_repository.dart';
import 'presentation/providers/personal_provider.dart';
import 'presentation/providers/ticket_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/booking_provider.dart';
import 'presentation/providers/onboarding_provider.dart';
import 'presentation/providers/group_provider.dart';
import 'presentation/providers/sync_provider.dart';
import 'presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DatabaseService();
  bool isDatabaseReady = false;

  try {
    await dbService.init();
    isDatabaseReady = true;
  } catch (e) {
    debugPrint("Isar initialization failed: $e");
  }

  ApiService? apiService;
  SyncService? syncService;

  if (isDatabaseReady) {
    const serverUrl = 'https://das-building-server.vercel.app';
    apiService = ApiService(baseUrl: serverUrl);
    syncService = SyncService(isar: dbService.isar, api: apiService);
    print('[Main] SyncService initialized with URL: $serverUrl');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: dbService),

        if (apiService != null) Provider<ApiService>.value(value: apiService),
        if (syncService != null)
          ChangeNotifierProvider<SyncProvider>(
            create: (_) => SyncProvider(syncService!),
          ),

        // Repositories that don't depend on DashboardProvider
        ProxyProvider<DatabaseService, MemberRepository>(
          update: (_, db, __) => IsarMemberRepository(db.isar),
        ),
        ProxyProvider<DatabaseService, PaymentRepository>(
          update: (_, db, __) => IsarPaymentRepository(db.isar),
        ),
        ProxyProvider<DatabaseService, BookingRepository>(
          update: (_, db, __) => IsarBookingRepository(db.isar),
        ),
        ProxyProvider<DatabaseService, AmenityRepository>(
          update: (_, db, __) => IsarAmenityRepository(db.isar),
        ),
        ProxyProvider<DatabaseService, AnnouncementRepository>(
          update: (_, db, __) => IsarAnnouncementRepository(db.isar),
        ),
        ProxyProvider<DatabaseService, MessageRepository>(
          update: (_, db, __) => IsarMessageRepository(db.isar),
        ),
        ProxyProvider<DatabaseService, GroupMemberRepository>(
          update: (_, db, __) => IsarGroupMemberRepository(db.isar),
        ),
        ProxyProvider<DatabaseService, GroupRepository>(
          update: (_, db, __) => IsarGroupRepository(db.isar),
        ),

        // DashboardProvider – needed by ExpenseRepository and TicketRepository below
        ChangeNotifierProxyProvider2<MemberRepository, PaymentRepository, DashboardProvider>(
          create: (context) => DashboardProvider(
            context.read<MemberRepository>(),
            context.read<PaymentRepository>(),
            apiService,
          ),
          update: (context, memberRepo, paymentRepo, previous) =>
              previous ?? DashboardProvider(memberRepo, paymentRepo, apiService),
        ),

        // Repositories that depend on DashboardProvider
        ProxyProvider2<DatabaseService, DashboardProvider, ExpenseRepository>(
          update: (_, db, memberProvider, __) => IsarExpenseRepository(
            db.isar,
            () => memberProvider.currentUser?.groupId ?? 'default_tenant',
          ),
        ),
        ProxyProvider2<DatabaseService, DashboardProvider, TicketRepository>(
          update: (_, db, memberProvider, __) => IsarTicketRepository(
            db.isar,
            () => memberProvider.currentUser?.groupId ?? 'default_tenant',
          ),
        ),

        // Providers
        ChangeNotifierProxyProvider2<ExpenseRepository, PaymentRepository, PersonalProvider>(
          create: (context) => PersonalProvider(
            context.read<ExpenseRepository>(),
            context.read<PaymentRepository>(),
          ),
          update: (context, expenseRepo, paymentRepo, previous) =>
              previous ?? PersonalProvider(expenseRepo, paymentRepo),
        ),
        ChangeNotifierProxyProvider<TicketRepository, TicketProvider>(
          create: (context) => TicketProvider(context.read<TicketRepository>()),
          update: (context, repo, previous) => previous ?? TicketProvider(repo),
        ),
        ChangeNotifierProxyProvider2<AnnouncementRepository, MessageRepository, ChatProvider>(
          create: (context) => ChatProvider(
            context.read<AnnouncementRepository>(),
            context.read<MessageRepository>(),
          ),
          update: (context, announcementRepo, messageRepo, previous) =>
              previous ?? ChatProvider(announcementRepo, messageRepo),
        ),
        ChangeNotifierProxyProvider2<AmenityRepository, BookingRepository, BookingProvider>(
          create: (context) => BookingProvider(
            context.read<AmenityRepository>(),
            context.read<BookingRepository>(),
          ),
          update: (context, amenityRepo, bookingRepo, previous) =>
              previous ?? BookingProvider(amenityRepo, bookingRepo),
        ),
        ChangeNotifierProxyProvider2<GroupMemberRepository, MemberRepository, OnboardingProvider>(
          create: (context) => OnboardingProvider(
            context.read<GroupMemberRepository>(),
            context.read<MemberRepository>(),
          ),
          update: (context, groupRepo, memberRepo, previous) =>
              previous ?? OnboardingProvider(groupRepo, memberRepo),
        ),
        ChangeNotifierProxyProvider3<GroupRepository, MemberRepository, DashboardProvider, GroupProvider>(
          create: (context) => GroupProvider(
            context.read<GroupRepository>(),
            context.read<MemberRepository>(),
            context.read<DashboardProvider>(),
          ),
          update: (context, groupRepo, memberRepo, memberProvider, previous) =>
              previous ?? GroupProvider(groupRepo, memberRepo, memberProvider),
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
    return MaterialApp(
      title: 'Civic Hearth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
