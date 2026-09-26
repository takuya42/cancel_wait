import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/available_slot.dart';
import '../models/notification_record.dart';
import '../models/shop.dart';
import '../models/waiting_customer.dart';

abstract interface class DashboardRepository {
  Stream<List<AvailableSlot>> watchSlots(String shopId);
  Stream<List<WaitingCustomer>> watchCustomers(String shopId);
  Stream<List<NotificationRecord>> watchNotifications(String shopId);
  Future<void> saveSlot(String shopId, AvailableSlot slot);
  Future<void> deleteSlot(String shopId, String id);
  Future<void> saveCustomer(String shopId, WaitingCustomer customer);
  Future<void> deleteCustomer(String shopId, String id);
  Future<void> sendMockNotifications(String shopId, AvailableSlot slot, List<WaitingCustomer> customers, String message);
  Future<void> updateShop(String shopId, {required String name, required String ownerName, required String phone, required String address});
  Future<void> reserve(String shopId, AvailableSlot slot, {required String name, required String phone});
}

class FirestoreDashboardRepository implements DashboardRepository {
  FirestoreDashboardRepository(this.db); final FirebaseFirestore db;
  CollectionReference<Map<String,dynamic>> _sub(String shop, String name)=>db.collection('shops').doc(shop).collection(name);
  @override Stream<List<AvailableSlot>> watchSlots(String id)=>_sub(id,'availableSlots').orderBy('startAt').snapshots().map((s)=>s.docs.map(AvailableSlot.fromDocument).toList());
  @override Stream<List<WaitingCustomer>> watchCustomers(String id)=>_sub(id,'waitingCustomers').orderBy('preferredDate').snapshots().map((s)=>s.docs.map(WaitingCustomer.fromDocument).toList());
  @override Stream<List<NotificationRecord>> watchNotifications(String id)=>_sub(id,'notifications').orderBy('createdAt',descending:true).snapshots().map((s)=>s.docs.map(NotificationRecord.fromDocument).toList());
  @override Future<void> saveSlot(String id, AvailableSlot slot) { final ref=slot.id.isEmpty?_sub(id,'availableSlots').doc():_sub(id,'availableSlots').doc(slot.id); return ref.set({...slot.toMap(),if(slot.id.isEmpty)'createdAt':FieldValue.serverTimestamp()},SetOptions(merge:true)); }
  @override Future<void> deleteSlot(String id,String slot)=>_sub(id,'availableSlots').doc(slot).delete();
  @override Future<void> saveCustomer(String id, WaitingCustomer c) { final ref=c.id.isEmpty?_sub(id,'waitingCustomers').doc():_sub(id,'waitingCustomers').doc(c.id); return ref.set({...c.toMap(),if(c.id.isEmpty)'createdAt':FieldValue.serverTimestamp()},SetOptions(merge:true)); }
  @override Future<void> deleteCustomer(String id,String customer)=>_sub(id,'waitingCustomers').doc(customer).delete();
  @override Future<void> sendMockNotifications(String id,AvailableSlot slot,List<WaitingCustomer> customers,String message) async { final batch=db.batch(); for(final c in customers){ batch.set(_sub(id,'notifications').doc(),{'slotId':slot.id,'customerId':c.id,'customerName':c.name,'message':message,'deliveryMode':'mock','status':'sent','createdAt':FieldValue.serverTimestamp()}); batch.update(_sub(id,'waitingCustomers').doc(c.id),{'status':'notified','notifiedAt':FieldValue.serverTimestamp(),'updatedAt':FieldValue.serverTimestamp()}); } await batch.commit(); }
  @override Future<void> updateShop(String id,{required String name,required String ownerName,required String phone,required String address})=>db.collection('shops').doc(id).update({'name':name.trim(),'ownerName':ownerName.trim(),'phone':phone.trim(),'address':address.trim(),'updatedAt':FieldValue.serverTimestamp()});
  @override Future<void> reserve(String shopId,AvailableSlot slot,{required String name,required String phone})=>db.runTransaction((tx) async { final ref=_sub(shopId,'availableSlots').doc(slot.id); final snapshot=await tx.get(ref); final current=AvailableSlot.fromDocument(snapshot); if(current.status!=SlotStatus.open||current.remainingCapacity<1) throw StateError('この枠は満席になりました。'); final next=current.remainingCapacity-1; final booking=_sub(shopId,'reservations').doc(); tx.update(ref,{'remainingCapacity':next,'status':next==0?'full':'open','updatedAt':FieldValue.serverTimestamp()}); tx.set(booking,{'slotId':slot.id,'name':name.trim(),'phone':phone.trim(),'status':'confirmed','createdAt':FieldValue.serverTimestamp()}); });
}

class DemoDashboardRepository implements DashboardRepository {
  final _slots=StreamController<List<AvailableSlot>>.broadcast(), _customers=StreamController<List<WaitingCustomer>>.broadcast(), _notifications=StreamController<List<NotificationRecord>>.broadcast();
  final slots=<AvailableSlot>[];
  final customers=<WaitingCustomer>[];
  final notifications=<NotificationRecord>[];
  void _emit(){_slots.add(List.of(slots));_customers.add(List.of(customers));_notifications.add(List.of(notifications));}
  @override Stream<List<AvailableSlot>> watchSlots(String id) async* {yield slots;yield* _slots.stream;}
  @override Stream<List<WaitingCustomer>> watchCustomers(String id) async* {yield customers;yield* _customers.stream;}
  @override Stream<List<NotificationRecord>> watchNotifications(String id) async* {yield notifications;yield* _notifications.stream;}
  @override Future<void> saveSlot(String id,AvailableSlot s)async{if(s.id.isEmpty){slots.add(s.copyWith(id:'slot-${DateTime.now().microsecondsSinceEpoch}'));}else{slots[slots.indexWhere((e)=>e.id==s.id)]=s;}_emit();}
  @override Future<void> deleteSlot(String id,String sid)async{slots.removeWhere((e)=>e.id==sid);_emit();}
  @override Future<void> saveCustomer(String id,WaitingCustomer c)async{if(c.id.isEmpty){customers.add(c.copyWith(id:'customer-${DateTime.now().microsecondsSinceEpoch}'));}else{customers[customers.indexWhere((e)=>e.id==c.id)]=c;}_emit();}
  @override Future<void> deleteCustomer(String id,String cid)async{customers.removeWhere((e)=>e.id==cid);_emit();}
  @override Future<void> sendMockNotifications(String id,AvailableSlot s,List<WaitingCustomer> cs,String message)async{for(final c in cs){notifications.insert(0,NotificationRecord(id:'n-${DateTime.now().microsecondsSinceEpoch}',slotId:s.id,customerId:c.id,customerName:c.name,message:message,deliveryMode:'mock',status:'sent',createdAt:DateTime.now())); final i=customers.indexWhere((e)=>e.id==c.id);if(i>=0)customers[i]=c.copyWith(status:WaitingStatus.notified,notifiedAt:DateTime.now());}_emit();}
  @override Future<void> updateShop(String id,{required String name,required String ownerName,required String phone,required String address})async{}
  @override Future<void> reserve(String id,AvailableSlot s,{required String name,required String phone})async{final i=slots.indexWhere((e)=>e.id==s.id);if(i<0||slots[i].remainingCapacity<1)throw StateError('満席です');final n=slots[i].remainingCapacity-1;slots[i]=slots[i].copyWith(remainingCapacity:n,status:n==0?SlotStatus.full:SlotStatus.open);_emit();}
}
