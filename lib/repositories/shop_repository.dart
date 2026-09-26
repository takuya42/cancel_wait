import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/shop.dart';

class ShopRepository {
  ShopRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Future<String> createOwnerShop({required String uid, required String shopName, required String ownerName, required String email}) async {
    final shop = _firestore.collection('shops').doc();
    final user = _firestore.collection('users').doc(uid);
    final batch = _firestore.batch();
    batch.set(shop, {
      'name': shopName.trim(), 'ownerUid': uid, 'ownerName': ownerName.trim(),
      'email': email.trim(), 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(), 'lineConnected': false,
    });
    batch.set(user, {
      'uid': uid, 'shopId': shop.id, 'name': ownerName.trim(),
      'email': email.trim(), 'role': 'owner', 'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return shop.id;
  }

  Stream<String?> watchShopId(String uid) => _firestore.collection('users').doc(uid).snapshots().map((doc) => doc.data()?['shopId'] as String?);
  Stream<Shop?> watchShop(String shopId) => _firestore.collection('shops').doc(shopId).snapshots().map((doc) => doc.exists ? Shop.fromDocument(doc) : null);
}
