import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'blocs/scanner/scanner_bloc.dart';
import 'blocs/document/document_bloc.dart';
import 'services/qr_scanner_service.dart';
import 'services/qr_decoder_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Lock to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ZimAuthenticatorApp());
}

class ZimAuthenticatorApp extends StatelessWidget {
  const ZimAuthenticatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<QRScannerService>(
          create: (context) => QRScannerService(),
        ),
        RepositoryProvider<QRDecoderService>(
          create: (context) => QRDecoderService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ScannerBloc>(
            create: (context) => ScannerBloc(
              scannerService: context.read<QRScannerService>(),
              decoderService: context.read<QRDecoderService>(),
            ),
          ),
          BlocProvider<DocumentBloc>(create: (context) => DocumentBloc()),
        ],
        child: MaterialApp(
          title: 'Zimbabwe Document Authenticator',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E3A8A), // Deep blue
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.transparent,
            ),
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
