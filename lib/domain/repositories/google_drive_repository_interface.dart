/// Google Drive API操作のリポジトリインターフェース
/// Data層で実装される
abstract class IGoogleDriveRepository {
  /// Google Drive APIのアクセストークンを取得
  Future<String> getAccessToken();

  /// ファイルを文字列としてダウンロード（設定ファイル用）
  /// [fileId] Google Drive File ID
  /// 戻り値: ファイルの内容（文字列）
  Future<String> downloadFileAsString(String fileId);

  /// ファイルをバイト配列としてダウンロード（画像・動画用）
  /// [fileId] Google Drive File ID
  /// 戻り値: ファイルの内容（バイト配列）
  Future<List<int>> downloadFileAsBytes(String fileId);

  /// ファイルメタデータを取得
  /// [fileId] Google Drive File ID
  /// 戻り値: ファイルメタデータ（Map形式）
  Future<Map<String, dynamic>> getFileMetadata(String fileId);

  /// URLまたはFile IDからFile IDを抽出
  /// [input] Google Drive共有URLまたはFile ID
  /// 戻り値: 抽出されたFile ID
  String extractFileId(String input);
}
