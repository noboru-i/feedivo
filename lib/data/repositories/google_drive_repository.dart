import '../../domain/repositories/google_drive_repository_interface.dart';
import '../services/google_drive_service.dart';

/// Google Drive API操作のリポジトリ実装
/// GoogleDriveServiceをラップして高レベルなAPIを提供
class GoogleDriveRepository implements IGoogleDriveRepository {
  GoogleDriveRepository({
    required GoogleDriveService driveService,
  }) : _driveService = driveService;

  final GoogleDriveService _driveService;

  @override
  Future<String> getAccessToken() {
    return _driveService.getAccessToken();
  }

  @override
  Future<String> downloadFileAsString(String fileId) {
    return _driveService.downloadFileAsString(fileId);
  }

  @override
  Future<List<int>> downloadFileAsBytes(String fileId) {
    return _driveService.downloadFileAsBytes(fileId);
  }

  @override
  Future<Map<String, dynamic>> getFileMetadata(String fileId) {
    return _driveService.getFileMetadata(fileId);
  }

  @override
  String extractFileId(String input) {
    return _driveService.extractFileId(input);
  }
}
