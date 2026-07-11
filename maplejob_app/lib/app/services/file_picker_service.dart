import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<FilePickerResult?> pickPdf() async {
    return FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
  }
}
