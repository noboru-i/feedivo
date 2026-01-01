import 'package:flutter/foundation.dart';

import '../../core/analytics/analytics_service.dart';
import '../../data/repositories/channel_repository.dart';
import '../../domain/entities/channel.dart';

/// チャンネル状態を管理するProvider
/// ChangeNotifierを使用してUIに状態変更を通知
class ChannelProvider extends ChangeNotifier {
  ChannelProvider(this._channelRepository, this._analyticsService);

  final ChannelRepository _channelRepository;
  final AnalyticsService _analyticsService;

  List<Channel> _channels = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Channel> get channels => _channels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// チャンネル一覧を読み込み
  Future<void> loadChannels(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _channels = await _channelRepository.getChannels(userId);
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = 'チャンネルの読み込みに失敗しました: $e';
      notifyListeners();
    }
  }

  /// チャンネルを追加
  Future<bool> addChannel(String userId, String configFileId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final channel = await _channelRepository.addChannel(userId, configFileId);
      _channels.insert(0, channel); // 先頭に追加
      _isLoading = false;
      notifyListeners();

      // Analytics: チャンネル追加
      await _analyticsService.logChannelAdded(
        channelId: channel.id,
        source: 'file_id_input',
      );

      return true;
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = 'チャンネルの追加に失敗しました: $e';
      notifyListeners();
      return false;
    }
  }

  /// チャンネルを削除
  Future<void> deleteChannel(String channelId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // チャンネルからuserIdを取得
      final channel = _channels.firstWhere((c) => c.id == channelId);
      await _channelRepository.deleteChannel(channel.userId, channelId);
      _channels.removeWhere((c) => c.id == channelId);
      _isLoading = false;
      notifyListeners();

      // Analytics: チャンネル削除
      await _analyticsService.logChannelDeleted(channelId: channelId);
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = 'チャンネルの削除に失敗しました: $e';
      notifyListeners();
    }
  }

  /// チャンネル設定を更新
  Future<void> refreshChannel(String channelId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // チャンネルからuserIdを取得
      final channel = _channels.firstWhere((c) => c.id == channelId);
      final updatedChannel = await _channelRepository.refreshChannel(
        channel.userId,
        channelId,
      );
      final index = _channels.indexWhere((c) => c.id == channelId);
      if (index != -1) {
        _channels[index] = updatedChannel;
      }
      _isLoading = false;
      notifyListeners();

      // Analytics: チャンネル更新
      await _analyticsService.logChannelRefreshed(channelId: channelId);
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = 'チャンネルの更新に失敗しました: $e';
      notifyListeners();
    }
  }

  /// エラーメッセージをクリア
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
