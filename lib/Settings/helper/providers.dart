import 'package:fresh_fold_shop_keeper/Features/auth/view_model.dart/auth_view_model.dart';
import 'package:fresh_fold_shop_keeper/Features/order_mangement/view_model/order_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../Features/PriceList/view_model/price_view.model.dart';
import '../../Features/wrapper/view_model/navigation_provider.dart';
import '../../Features/order_detial/view_model.dart/oder_detail_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => AuthViewModel()),
  ChangeNotifierProvider(create: (_) => NavigationProvider()),
  ChangeNotifierProvider(create: (_) => ShopkeeperOrderViewModel()),
  ChangeNotifierProvider(create: (_) => PriceViewModel()),
  ChangeNotifierProvider(create: (_) => OrderDetailViewModel()),
];
