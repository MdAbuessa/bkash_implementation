import 'package:flutter/material.dart';
import 'services/bkash_service.dart';
import 'theme/bkash_theme.dart';
import 'views/bkash_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bkashService = BkashService();
  await bkashService.init();

  runApp(BkashApp(bkashService: bkashService));
}

class BkashApp extends StatelessWidget {
  final BkashService bkashService;

  const BkashApp({super.key, required this.bkashService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bKash App',
      debugShowCheckedModeBanner: false,
      theme: BkashTheme.lightTheme,
      home: BkashLoginScreen(bkashService: bkashService),
    );
  }
}
