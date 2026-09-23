import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/app_constants.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(String code) onScanned;
  final String promptTitle;
  final String manualHint;
  final bool showManualFallback;
  final double? height;

  const QRScannerWidget({
    super.key,
    required this.onScanned,
    this.promptTitle = 'Align QR Code within the frame',
    this.manualHint = 'Enter Code Manually',
    this.showManualFallback = true,
    this.height,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _isTorchOn = false;
  bool _hasScanned = false;
  final TextEditingController _manualController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_hasScanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        _hasScanned = true;
        widget.onScanned(rawValue.trim());
        break;
      }
    }
  }

  void _submitManual() {
    final text = _manualController.text.trim();
    if (text.isNotEmpty) {
      widget.onScanned(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Camera Viewport with Industrial Reticle
        Container(
          height: widget.height ?? 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: AppConstants.borderRadius,
            boxShadow: AppConstants.softShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _handleBarcode,
                errorBuilder: (context, error, child) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videocam_off, color: Colors.white70, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Camera Unavailable or No Permission',
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please use manual input below to continue offline.',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Industrial Scanning Reticle Overlay
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppConstants.primaryBlue, width: 2.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Top Left Corner
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 4),
                              left: BorderSide(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                      ),
                      // Top Right Corner
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 4),
                              right: BorderSide(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                      ),
                      // Bottom Left Corner
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 4),
                              left: BorderSide(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                      ),
                      // Bottom Right Corner
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 4),
                              right: BorderSide(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white30,
                          size: 64,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Camera controls on top
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: Icon(
                          _isTorchOn ? Icons.flash_on : Icons.flash_off,
                          color: _isTorchOn ? Colors.amber : Colors.white,
                          size: 20,
                        ),
                        onPressed: () async {
                          await _controller.toggleTorch();
                          setState(() {
                            _isTorchOn = !_isTorchOn;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 20),
                        onPressed: () => _controller.switchCamera(),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Prompt
              Positioned(
                bottom: 12,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black70,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.promptTitle,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.showManualFallback) ...[
          const SizedBox(height: 16),
          // Manual Input Fallback Section
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: widget.manualHint,
                    prefixIcon: const Icon(Icons.keyboard_outlined, color: AppConstants.primaryBlue),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (_) => _submitManual(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _submitManual,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppConstants.borderRadius),
                  minimumSize: const Size(60, 56),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
