import 'package:flutter/foundation.dart';

import '../../domain/entities/playback_position.dart';
import '../../domain/repositories/playback_repository_interface.dart';

/// 視聴位置状態を管理するProvider
/// ChangeNotifierを使用してUIに状態変更を通知
class PlaybackProvider extends ChangeNotifier {
  PlaybackProvider(this._playbackRepository);

  final IPlaybackRepository _playbackRepository;

  final Map<String, PlaybackPosition> _positions = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, PlaybackPosition> get positions => _positions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 指定された動画の視聴位置を取得
  PlaybackPosition? getPosition(String videoId) {
    return _positions[videoId];
  }

  /// 視聴位置を読み込み
  Future<void> loadPosition(String userId, String videoId) async {
    try {
      final position = await _playbackRepository.getPlaybackPosition(
        userId,
        videoId,
      );
      if (position != null) {
        _positions[videoId] = position;
        notifyListeners();
      }
    } on Exception catch (e) {
      _errorMessage = '視聴位置の読み込みに失敗しました: $e';
      notifyListeners();
    }
  }

  /// 視聴位置を保存
  Future<void> savePosition(
    String userId,
    PlaybackPosition position,
  ) async {
    try {
      await _playbackRepository.savePlaybackPosition(userId, position);
      _positions[position.videoId] = position;
      notifyListeners();
    } on Exception catch (e) {
      _errorMessage = '視聴位置の保存に失敗しました: $e';
      notifyListeners();
    }
  }

  /// 動画を視聴完了としてマーク
  Future<void> markCompleted(String userId, String videoId) async {
    try {
      await _playbackRepository.markAsCompleted(userId, videoId);
      final position = _positions[videoId];
      if (position != null) {
        _positions[videoId] = position.copyWith(isCompleted: true);
        notifyListeners();
      }
    } on Exception catch (e) {
      _errorMessage = '視聴完了のマークに失敗しました: $e';
      notifyListeners();
    }
  }

  /// 視聴履歴を読み込み
  Future<void> loadHistory(String userId, {int? limit}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final history = await _playbackRepository.getPlaybackHistory(
        userId,
        limit: limit,
      );
      for (final position in history) {
        _positions[position.videoId] = position;
      }
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = '視聴履歴の読み込みに失敗しました: $e';
      notifyListeners();
    }
  }

  /// エラーメッセージをクリア
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
