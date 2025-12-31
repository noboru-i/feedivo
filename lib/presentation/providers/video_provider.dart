import 'package:flutter/foundation.dart';

import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository_interface.dart';

/// 動画状態を管理するProvider
/// ChangeNotifierを使用してUIに状態変更を通知
class VideoProvider extends ChangeNotifier {
  VideoProvider(this._videoRepository);

  final IVideoRepository _videoRepository;

  List<Video> _videos = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Video> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 動画一覧を読み込み
  Future<void> loadVideos(String channelId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _videos = await _videoRepository.getVideos(channelId);
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = '動画の読み込みに失敗しました: $e';
      notifyListeners();
    }
  }

  /// チャンネル設定ファイルから動画リストを同期
  Future<void> syncVideos(String channelId, List<dynamic> videos) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _videoRepository.syncVideosFromConfig(channelId, videos);
      // 同期後、最新の動画リストを再読み込み
      _videos = await _videoRepository.getVideos(channelId);
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = '動画の同期に失敗しました: $e';
      notifyListeners();
    }
  }

  /// エラーメッセージをクリア
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 動画リストをクリア（チャンネル切り替え時など）
  void clearVideos() {
    _videos = [];
    _errorMessage = null;
    notifyListeners();
  }
}
