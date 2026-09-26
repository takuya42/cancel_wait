import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/available_slot.dart';
import '../models/notification_record.dart';
import '../models/waiting_customer.dart';
import '../repositories/dashboard_repository.dart';
import '../services/matching_service.dart';
import 'auth_providers.dart';

final demoDashboardRepositoryProvider=Provider((ref)=>DemoDashboardRepository());
final dashboardRepositoryProvider=Provider<DashboardRepository>((ref)=>ref.watch(isDemoModeProvider)?ref.watch(demoDashboardRepositoryProvider):FirestoreDashboardRepository(FirebaseFirestore.instance));
final slotsProvider=StreamProvider<List<AvailableSlot>>((ref){final id=ref.watch(shopIdProvider).value;return id==null?Stream.value([]):ref.watch(dashboardRepositoryProvider).watchSlots(id);});
final waitingCustomersProvider=StreamProvider<List<WaitingCustomer>>((ref){final id=ref.watch(shopIdProvider).value;return id==null?Stream.value([]):ref.watch(dashboardRepositoryProvider).watchCustomers(id);});
final notificationsProvider=StreamProvider<List<NotificationRecord>>((ref){final id=ref.watch(shopIdProvider).value;return id==null?Stream.value([]):ref.watch(dashboardRepositoryProvider).watchNotifications(id);});
final matchingServiceProvider=Provider((ref)=>const MatchingService());
