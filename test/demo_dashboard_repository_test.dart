import 'package:cancel_wait/models/available_slot.dart';
import 'package:cancel_wait/models/waiting_customer.dart';
import 'package:cancel_wait/repositories/dashboard_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const shopId = 'demo-shop';

  test('テストモードはすべての管理データが0件で始まる', () async {
    final repository = DemoDashboardRepository();

    expect(await repository.watchSlots(shopId).first, isEmpty);
    expect(await repository.watchCustomers(shopId).first, isEmpty);
    expect(await repository.watchNotifications(shopId).first, isEmpty);
  });

  test('テストモードで登録と通知をインメモリで試せる', () async {
    final repository = DemoDashboardRepository();
    final now = DateTime(2026, 9, 26, 10);
    final slot = AvailableSlot(
      id: '',
      startAt: now,
      endAt: now.add(const Duration(hours: 1)),
      menuName: '整体60分',
      staffName: '田中',
      capacity: 1,
      remainingCapacity: 1,
      memo: '',
      status: SlotStatus.open,
      createdAt: now,
    );
    final customer = WaitingCustomer(
      id: '',
      name: '田中 太郎',
      preferredDate: now,
      preferredStartTime: '09:00',
      preferredEndTime: '12:00',
      menuName: '整体60分',
      phone: '090-0000-0000',
      lineLinked: false,
      memo: '',
      status: WaitingStatus.waiting,
      createdAt: now,
    );

    await repository.saveSlot(shopId, slot);
    await repository.saveCustomer(shopId, customer);
    expect(repository.slots, hasLength(1));
    expect(repository.customers, hasLength(1));

    await repository.sendMockNotifications(
      shopId,
      repository.slots.single,
      [repository.customers.single],
      '空き枠があります',
    );
    expect(repository.notifications, hasLength(1));
    expect(repository.customers.single.status, WaitingStatus.notified);

    await repository.deleteSlot(shopId, repository.slots.single.id);
    await repository.deleteCustomer(shopId, repository.customers.single.id);
    expect(repository.slots, isEmpty);
    expect(repository.customers, isEmpty);
  });
}
