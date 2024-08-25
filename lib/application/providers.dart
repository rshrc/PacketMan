// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:packet_man/application/app_provider.dart';
import 'package:packet_man/di/injection.dart';

final providers = [
  ChangeNotifierProvider<AppProvider>(
    create: (_) => getIt<AppProvider>(),
    lazy: false,
  ),
];
