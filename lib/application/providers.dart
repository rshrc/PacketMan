import 'package:packet_man/application/app_provider.dart';
import 'package:packet_man/di/injection.dart';
import 'package:provider/provider.dart';

final providers = [
  ChangeNotifierProvider<AppProvider>(
    create: (_) => getIt<AppProvider>(),
  ),
];
