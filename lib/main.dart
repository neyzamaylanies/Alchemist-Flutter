import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'repositories/auth_repository.dart';
import 'utils/app_theme.dart';
import 'utils/remote_helper.dart';
import 'utils/routes.dart';
import 'utils/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: BlocProvider(
        create: (_) =>
            AuthBloc(AuthRepository(RemoteHelper.getDio()))
              ..add(AuthCheckRequested()),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              title: 'Alchemist - Inventory Laboratorium',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              initialRoute: Routes.splash,
              routes: Routes.routes,
              onGenerateRoute: Routes.onGenerateRoute,
            );
          },
        ),
      ),
    );
  }
}
