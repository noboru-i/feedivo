import 'package:flutter/foundation.dart';

import '../../domain/entities/channel.dart';
import '../../domain/repositories/channel_repository_interface.dart';

/// チャンネル状態を管理するProvider
/// ChangeNotifierを使用してUIに状態変更を通知
class ChannelProvider extends ChangeNotifier {
  ChannelProvider(this._channelRepository);

  final IChannelRepository _channelRepository;

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
      final channel =
          await _channelRepository.addChannel(userId, configFileId);
      _channels.insert(0, channel); // 先頭に追加
      _isLoading = false;
      notifyListeners();
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
      await _channelRepository.deleteChannel(channelId);
      _channels.removeWhere((c) => c.id == channelId);
      _isLoading = false;
      notifyListeners();
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
      final updatedChannel = await _channelRepository.refreshChannel(channelId);
      final index = _channels.indexWhere((c) => c.id == channelId);
      if (index != -1) {
        _channels[index] = updatedChannel;
      }
      _isLoading = false;
      notifyListeners();
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
