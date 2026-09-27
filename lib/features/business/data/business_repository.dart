import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/business_profile.dart';
class BusinessRepository { BusinessRepository(this.firestore); final FirebaseFirestore firestore; Stream<BusinessProfile> watch(String id) => firestore.collection('organizations').doc(id).snapshots().map(BusinessProfile.fromDocument); Future<void> save(String id, BusinessProfile profile) => firestore.collection('organizations').doc(id).set(profile.toMap(), SetOptions(merge: true)); }
