import 'package:flutter/foundation.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/errors/exceptions.dart';
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
    debugPrint('[ChannelProvider] チャンネル一覧読み込み開始: userId=$userId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _channels = await _channelRepository.getChannels(userId);
      _isLoading = false;
      notifyListeners();
      debugPrint('[ChannelProvider] チャンネル一覧読み込み成功: ${_channels.length}件');
    } on Exception catch (e, stackTrace) {
      debugPrint('[ChannelProvider] チャンネル一覧読み込み失敗: $e');
      debugPrint('[ChannelProvider] スタックトレース: $stackTrace');
      _isLoading = false;
      _errorMessage = 'チャンネルの読み込みに失敗しました: $e';
      notifyListeners();
    }
  }

  /// チャンネルを追加
  Future<bool> addChannel(String userId, String configFileId) async {
    debugPrint('[ChannelProvider] チャンネル追加開始: userId=$userId, fileId=$configFileId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final channel = await _channelRepository.addChannel(userId, configFileId);
      _channels.insert(0, channel); // 先頭に追加
      _isLoading = false;
      notifyListeners();

      debugPrint('[ChannelProvider] チャンネル追加成功: ${channel.id}');

      // Analytics: チャンネル追加
      await _analyticsService.logChannelAdded(
        channelId: channel.id,
        source: 'file_id_input',
      );

      return true;
    } on UnauthorizedException catch (e) {
      // 認証エラーの場合は、エラーメッセージをそのまま表示
      debugPrint('[ChannelProvider] UnauthorizedException: ${e.message}');
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on PermissionDeniedException catch (e, stackTrace) {
      // 権限エラーの場合は、わかりやすいメッセージを表示
      debugPrint('[ChannelProvider] PermissionDeniedException: $e');
      debugPrint('[ChannelProvider] スタックトレース: $stackTrace');
      _isLoading = false;
      _errorMessage = 'ファイルへのアクセス権限がありません。\n'
          'Google Driveの共有設定を確認してください。';
      notifyListeners();
      return false;
    } on FileNotFoundException catch (e, stackTrace) {
      // ファイルが見つからない場合のエラーメッセージ
      debugPrint('[ChannelProvider] FileNotFoundException: $e');
      debugPrint('[ChannelProvider] スタックトレース: $stackTrace');
      _isLoading = false;
      _errorMessage = 'ファイルが見つかりません。\nURLまたはFile IDを確認してください。';
      notifyListeners();
      return false;
    } on InvalidConfigException catch (e, stackTrace) {
      // 設定ファイルのフォーマットエラー
      debugPrint('[ChannelProvider] InvalidConfigException: ${e.message}');
      debugPrint('[ChannelProvider] スタックトレース: $stackTrace');
      _isLoading = false;
      _errorMessage = '設定ファイルの形式が正しくありません。\n${e.message}';
      notifyListeners();
      return false;
    } on Exception catch (e, stackTrace) {
      debugPrint('[ChannelProvider] Exception: $e');
      debugPrint('[ChannelProvider] スタックトレース: $stackTrace');
      _isLoading = false;
      _errorMessage = 'チャンネルの追加に失敗しました: $e';
      notifyListeners();
      return false;
    }
  }

  /// チャンネルを削除
  Future<void> deleteChannel(String channelId) async {
    debugPrint('[ChannelProvider] チャンネル削除開始: $channelId');
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

      debugPrint('[ChannelProvider] チャンネル削除成功: $channelId');

      // Analytics: チャンネル削除
      await _analyticsService.logChannelDeleted(channelId: channelId);
    } on Exception catch (e, stackTrace) {
      debugPrint('[ChannelProvider] チャンネル削除失敗: $e');
      debugPrint('[ChannelProvider] スタックトレース: $stackTrace');
      _isLoading = false;
      _errorMessage = 'チャンネルの削除に失敗しました: $e';
      notifyListeners();
    }
  }

  /// チャンネル設定を更新
  Future<void> refreshChannel(String channelId) async {
    debugPrint('[ChannelProvider] チャンネル更新開始: $channelId');
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

      debugPrint('[ChannelProvider] チャンネル更新成功: $channelId');

      // Analytics: チャンネル更新
      await _analyticsService.logChannelRefreshed(channelId: channelId);
    } on UnauthorizedException catch (e) {
      // 認証エラーの場合は、エラーメッセージをそのまま表示
      debugPrint('[ChannelProvider] UnauthorizedException: ${e.message}');
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
    } on PermissionDeniedException catch (e, stackTrace) {
      // 権限エラーの場合は、わかりやすいメッセージを表示
      debugPrint('[ChannelProvider] PermissionDeniedException: $e');
      debugPrint('[ChannelProvider] スタックトレース: $stackTrace');
      _isLoading = false;
      _errorMessage = 'ファイルへのアクセス権限がありません。\n'
          'Google Driveの共有設定を確認してください。';
      notifyListeners();
    } on FileNotFoundException catch (e, stackTrace) {
      // ファイルが見つからない場合のエラーメッセージ
      debugPrint('[ChannelProvider] FileNotFoundException: $e');
      debugPrint('[ChannelProvider] スタックトレース: $stackTrace');
      _isLoading = false;
      _errorMessage = 'ファイルが見つかりません。';
      notifyListeners();
    } on InvalidConfigException catch (e, stackTrace) {
      // 設定ファイルのフォーマットエラー
      debugPrint('[ChannelProvider] InvalidConfigException: ${e.message}');
      debugPrint('[ChannelProvider] スタックトレース: $stackTrace');
      _isLoading = false;
      _errorMessage = '設定ファイルの形式が正しくありません。\n${e.message}';
      notifyListeners();
    } on Exception catch (e, stackTrace) {
      debugPrint('[ChannelProvider] Exception: $e');
      debugPrint('[ChannelProvider] スタックトレース: $stackTrace');
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
