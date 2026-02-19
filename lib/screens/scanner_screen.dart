import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zimauthenticator/blocs/scanner/scanner_event.dart';
import 'package:zimauthenticator/blocs/scanner/scanner_state.dart';
import '../blocs/scanner/scanner_bloc.dart';
import 'document_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _controller.stop();
        break;
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Permission Required'),
        content: Text(
          'Please grant camera permission to scan QR codes. You can enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code != null && code.isNotEmpty) {
      setState(() {
        _hasScanned = true;
      });

      // Trigger decryption via BLoC
      context.read<ScannerBloc>().add(QRCodeDetected(code));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<ScannerBloc, ScannerState>(
        listener: (context, state) {
          if (state is ScannerSuccess) {
            // Navigate to document detail screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    DocumentDetailScreen(document: state.document),
              ),
            );
          } else if (state is ScannerError) {
            // Show error dialog
            _showErrorDialog(state.message);
            setState(() {
              _hasScanned = false;
            });
          }
        },
        child: BlocBuilder<ScannerBloc, ScannerState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Camera view
                MobileScanner(controller: _controller, onDetect: _onDetect),

                // Overlay
                _buildScannerOverlay(state),

                // Top bar
                _buildTopBar(),

                // Bottom instructions
                _buildBottomSection(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScannerOverlay(ScannerState state) {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: Stack(
        children: [
          // Dark overlay with transparent center
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.all(60),
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scan frame
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.all(60),
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: state is ScannerProcessing
                      ? Colors.orange
                      : Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Corner decorations
                  ..._buildCornerDecorations(state),

                  // Loading indicator when processing
                  if (state is ScannerProcessing)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            const SizedBox(height: 12),
                            Text(
                              'Decrypting...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerDecorations(ScannerState state) {
    final color = state is ScannerProcessing ? Colors.orange : Colors.white;

    return [
      // Top-left
      Positioned(
        top: -2,
        left: -2,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: 4),
              left: BorderSide(color: color, width: 4),
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: -2,
        right: -2,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: 4),
              right: BorderSide(color: color, width: 4),
            ),
            borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: -2,
        left: -2,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: 4),
              left: BorderSide(color: color, width: 4),
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: -2,
        right: -2,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: 4),
              right: BorderSide(color: color, width: 4),
            ),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
          ),
        ),
      ),
    ];
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            IconButton(
              onPressed: () => _controller.toggleTorch(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: ValueListenableBuilder(
                  valueListenable: _controller.torchState,
                  builder: (context, state, child) {
                    return Icon(
                      state == TorchState.on
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(ScannerState state) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state is ScannerInitial) ...[
                Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'Position QR code within frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scanning will start automatically',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ] else if (state is ScannerProcessing) ...[
                Text(
                  'Processing QR Code...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we decrypt the data',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Text('Scan Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
