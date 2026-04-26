import 'package:card_reader_app/Data/Models/scan_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// created a notifier as we can alter it but a provider we can't
class ScanRequestNotifier extends Notifier<ScanRequest> {
  // instead a constructor we need to create the instance in a build method
  @override
  build() {
    return const ScanRequest();
  }

  // here is the methods of the notifier

  /// pass the notifier state parameters for any of this function parameters that are null otherwise it will be updated
  void updateScanRequest({
    XFile? firstImageXFile,
    XFile? secondImageXFile,
    bool? isThresholdUsed,
    bool? isSmartCropUsed,
  }) {
    state = ScanRequest(
      firstImageXFile: firstImageXFile ?? state.firstImageXFile,
      secondImageXFile: secondImageXFile ?? state.secondImageXFile,
      isThresholdUsed: isThresholdUsed ?? state.isThresholdUsed,
      isSmartCropUsed: isSmartCropUsed ?? state.isSmartCropUsed,
    );
  }

  void removeImage(bool isFirstImage) {
    /// remove the image from the state based on the bool
    if (isFirstImage) {
      state = ScanRequest(
        firstImageXFile: null,
        secondImageXFile: state.secondImageXFile,
        isThresholdUsed: state.isThresholdUsed,
        isSmartCropUsed: state.isSmartCropUsed,
      );
    } else {
      state = ScanRequest(
        firstImageXFile: state.firstImageXFile,
        secondImageXFile: null,
        isThresholdUsed: state.isThresholdUsed,
        isSmartCropUsed: state.isSmartCropUsed,
      );
    }
  }

  void resetRequest() {
    state = const ScanRequest();
  }
}

//to be able to use the notifier we need to create a variable that will be the provider
// the first thing in the generic type is the notifier class then the class used in the provider
//then  in the constructor we will return the notifier to be listened to
final scanRequestProvider = NotifierProvider<ScanRequestNotifier, ScanRequest>(
  () {
    return ScanRequestNotifier();
  },
);
