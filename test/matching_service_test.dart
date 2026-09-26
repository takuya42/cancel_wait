import 'package:cancel_wait/models/available_slot.dart';
import 'package:cancel_wait/models/waiting_customer.dart';
import 'package:cancel_wait/services/matching_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final day = DateTime(2026, 9, 28);
  final slot = AvailableSlot(
    id: 'slot', startAt: DateTime(2026, 9, 28, 15),
    endAt: DateTime(2026, 9, 28, 16), menuName: '整体60分',
    staffName: '田中', capacity: 1, remainingCapacity: 1, memo: '',
    status: SlotStatus.open, createdAt: day,
  );
  WaitingCustomer customer({String menu = '整体60分', String start = '14:00',
    String end = '17:00', WaitingStatus status = WaitingStatus.waiting}) =>
      WaitingCustomer(id: 'customer', name: '田中 太郎', preferredDate: day,
        preferredStartTime: start, preferredEndTime: end, menuName: menu,
        phone: '', lineLinked: true, memo: '', status: status, createdAt: day);

  test('同日・同メニュー・重複時間の待機顧客に一致する', () {
    expect(const MatchingService().matches(slot, customer()), isTrue);
  });
  test('メニュー不一致または通知済み顧客には一致しない', () {
    expect(const MatchingService().matches(slot, customer(menu: '骨盤矯正')), isFalse);
    expect(const MatchingService().matches(slot,
      customer(status: WaitingStatus.notified)), isFalse);
  });
  test('時間帯が重ならない顧客には一致しない', () {
    expect(const MatchingService().matches(slot,
      customer(start: '16:00', end: '18:00')), isFalse);
  });
}
