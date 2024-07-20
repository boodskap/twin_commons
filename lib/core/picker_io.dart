import 'package:file_picker/file_picker.dart';

Future<FilePickerResult?> pickFiles({
  String? dialogTitle,
  String? initialDirectory,
  FileType type = FileType.any,
  List<String>? allowedExtensions,
  Function(FilePickerStatus)? onFileLoading,
  bool allowCompression = true,
  int compressionQuality = 30,
  bool allowMultiple = false,
  bool withData = false,
  bool withReadStream = false,
  bool lockParentWindow = false,
  bool readSequential = false,
}) async {
  return FilePicker.platform.pickFiles(
    dialogTitle: dialogTitle,
    initialDirectory: initialDirectory,
    type: type,
    allowCompression: allowCompression,
    allowedExtensions: allowedExtensions,
    compressionQuality: compressionQuality,
    allowMultiple: allowMultiple,
    withData: withData,
    withReadStream: withReadStream,
    lockParentWindow: lockParentWindow,
    readSequential: readSequential,
    onFileLoading: onFileLoading,
  );
}
