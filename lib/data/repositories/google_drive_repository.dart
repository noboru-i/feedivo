import '../services/google_drive_service.dart';

/// Google Drive API操作のリポジトリ実装
/// GoogleDriveServiceをラップして高レベルなAPIを提供
class GoogleDriveRepository {
  GoogleDriveRepository({
    required GoogleDriveService driveService,
  }) : _driveService = driveService;

  final GoogleDriveService _driveService;

  Future<String> getAccessToken() {
    return _driveService.getAccessToken();
  }

  Future<String> downloadFileAsString(String fileId) {
    return _driveService.downloadFileAsString(fileId);
  }

  Future<List<int>> downloadFileAsBytes(String fileId) {
    return _driveService.downloadFileAsBytes(fileId);
  }

  Future<Map<String, dynamic>> getFileMetadata(String fileId) {
    return _driveService.getFileMetadata(fileId);
  }

  Future<List<Map<String, dynamic>>> listFilesInFolder(
    String folderId, {
    String? mimeTypeFilter,
  }) {
    return _driveService.listFilesInFolder(
      folderId,
      mimeTypeFilter: mimeTypeFilter,
    );
  }

  String extractFileId(String input) {
    return _driveService.extractFileId(input);
  }
}
