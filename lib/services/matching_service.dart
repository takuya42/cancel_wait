import '../models/available_slot.dart';
import '../models/waiting_customer.dart';

/// Pure matching policy. Add future conditions here without coupling them to UI.
class MatchingService {
  const MatchingService();
  List<WaitingCustomer> candidates(AvailableSlot slot, Iterable<WaitingCustomer> customers) => customers.where((c) => matches(slot, c)).toList();
  bool matches(AvailableSlot slot, WaitingCustomer customer) {
    if (customer.status != WaitingStatus.waiting || slot.status != SlotStatus.open || slot.remainingCapacity < 1) return false;
    final sameDay = slot.startAt.year == customer.preferredDate.year && slot.startAt.month == customer.preferredDate.month && slot.startAt.day == customer.preferredDate.day;
    final preferredStart = _at(customer.preferredDate, customer.preferredStartTime);
    final preferredEnd = _at(customer.preferredDate, customer.preferredEndTime);
    return sameDay && customer.menuName.trim().toLowerCase() == slot.menuName.trim().toLowerCase() && slot.startAt.isBefore(preferredEnd) && slot.endAt.isAfter(preferredStart);
  }
  DateTime _at(DateTime day, String hhmm) { final p=hhmm.split(':').map(int.parse).toList(); return DateTime(day.year,day.month,day.day,p[0],p[1]); }
}
