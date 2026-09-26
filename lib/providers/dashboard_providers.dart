import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/waiting_customer.dart';

final waitingCustomersProvider = Provider<List<WaitingCustomer>>((ref) {
  return const [
    WaitingCustomer(name: '山田 花子', preferredDate: '9月28日', preferredTime: '14:00〜17:00', menu: '整体60分', isLineConnected: true, registeredAt: '9月25日 10:32'),
    WaitingCustomer(name: '佐藤 美咲', preferredDate: '9月29日', preferredTime: '10:00〜13:00', menu: '骨盤矯正', isLineConnected: true, registeredAt: '9月25日 09:15'),
    WaitingCustomer(name: '鈴木 健太', preferredDate: '9月30日', preferredTime: '終日', menu: 'パーソナルケア90分', isLineConnected: false, registeredAt: '9月24日 18:40'),
    WaitingCustomer(name: '高橋 葵', preferredDate: '10月1日', preferredTime: '16:00〜19:00', menu: '整体60分', isLineConnected: true, registeredAt: '9月24日 14:08'),
    WaitingCustomer(name: '伊藤 直樹', preferredDate: '10月2日', preferredTime: '11:00〜14:00', menu: 'ボディケア30分', isLineConnected: true, registeredAt: '9月23日 16:22'),
  ];
});
