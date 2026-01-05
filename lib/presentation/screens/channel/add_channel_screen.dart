import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/channel_provider.dart';

/// チャンネル追加画面
/// Google Drive File IDまたはURLを入力してチャンネルを追加
class AddChannelScreen extends StatefulWidget {
  const AddChannelScreen({super.key});

  @override
  State<AddChannelScreen> createState() => _AddChannelScreenState();
}

class _AddChannelScreenState extends State<AddChannelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fileIdController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _fileIdController.dispose();
    super.dispose();
  }

  String? _validateFileId(String? value) {
    if (value == null || value.isEmpty) {
      return 'File IDまたはURLを入力してください';
    }

    // URLの場合は複数パターンに対応
    if (value.contains('drive.google.com')) {
      // パターン1: /d/FILE_ID
      // パターン2: /drive/folders/FOLDER_ID
      // パターン3: /open?id=FILE_ID
      final patterns = [
        RegExp(r'/d/([a-zA-Z0-9_-]+)'),
        RegExp(r'/drive/folders/([a-zA-Z0-9_-]+)'),
        RegExp(r'/open\?id=([a-zA-Z0-9_-]+)'),
      ];

      final hasMatch = patterns.any((pattern) => pattern.hasMatch(value));
      if (!hasMatch) {
        return '有効なGoogle Drive URLではありません';
      }
    } else {
      // File IDの場合は英数字、ハイフン、アンダースコアのみ
      final fileIdPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
      if (!fileIdPattern.hasMatch(value)) {
        return '有効なFile IDではありません';
      }
    }

    return null;
  }

  Future<void> _handleAddChannel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final channelProvider = context.read<ChannelProvider>();

    final userId = authProvider.currentUser?.uid;
    if (userId == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ユーザーが見つかりません')),
      );
      return;
    }

    setState(() {
      _isAdding = true;
    });

    final success = await channelProvider.addChannel(
      userId,
      _fileIdController.text.trim(),
    );

    setState(() {
      _isAdding = false;
    });

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('チャンネルを追加しました')),
      );
      Navigator.of(context).pop();
    } else {
      // エラーメッセージはChannelProviderのerrorMessageに設定されている
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(channelProvider.errorMessage ?? 'チャンネルの追加に失敗しました'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャンネル追加'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.spacingL),

              // 説明テキスト
              Text(
                'Google Driveのファイル・フォルダのIDまたは\n共有URLを入力してください',
                style: AppTypography.body1.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spacingXL),

              // File ID入力フィールド
              TextFormField(
                controller: _fileIdController,
                enabled: !_isAdding,
                decoration: InputDecoration(
                  labelText: 'File ID / Folder ID / URL',
                  hintText: 'ファイルURL、フォルダURL、またはIDを貼り付け',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.folder),
                ),
                validator: _validateFileId,
                maxLines: 3,
                minLines: 1,
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: AppDimensions.spacingS),

              // ヘルプテキスト
              Text(
                'JSONファイル、フォルダURL、またはIDを貼り付けてください',
                style: AppTypography.caption.copyWith(
                  color: AppColors.disabledText,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXL),

              // 追加ボタン
              ElevatedButton(
                onPressed: _isAdding ? null : _handleAddChannel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  elevation: 0,
                ),
                child: _isAdding
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'チャンネルを追加',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // 説明カード
              Card(
                color: AppColors.surfaceColor,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.infoColor,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.spacingS),
                          Text(
                            'ヒント',
                            style: AppTypography.h3.copyWith(
                              color: AppColors.infoColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Text(
                        '設定ファイル（JSON形式）またはフォルダのURLを入力できます。フォルダの場合は、配下の動画ファイルが自動的に検出されます。詳しい手順はドキュメントを参照してください。',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
