import 'package:image_picker/image_picker.dart';

class ScanRequest {
  final XFile? firstImageXFile;
  final bool isSmartCropUsed;
  final bool isThresholdUsed;
  final XFile? secondImageXFile;

  const ScanRequest({
    this.firstImageXFile,
    this.secondImageXFile,
    this.isThresholdUsed = false,
    this.isSmartCropUsed = false,
  });
}
