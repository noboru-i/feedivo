/// 視聴位置エンティティ
/// ドメイン層のビジネスロジックで使用する純粋なDartオブジェクト
class PlaybackPosition {
  PlaybackPosition({
    required this.videoId,
    required this.channelId,
    required this.position,
    required this.duration,
    required this.lastPlayedAt,
    required this.isCompleted,
  });
  final String videoId;
  final String channelId;
  final int position; // 秒数
  final int duration; // 秒数
  final DateTime lastPlayedAt;
  final bool isCompleted;

  /// 視聴進捗率（0.0 - 1.0）
  double get watchPercentage {
    if (duration <= 0) {
      return 0;
    }
    final percentage = position / duration;
    return percentage.clamp(0, 1);
  }

  PlaybackPosition copyWith({
    String? videoId,
    String? channelId,
    int? position,
    int? duration,
    DateTime? lastPlayedAt,
    bool? isCompleted,
  }) {
    return PlaybackPosition(
      videoId: videoId ?? this.videoId,
      channelId: channelId ?? this.channelId,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PlaybackPosition &&
        other.videoId == videoId &&
        other.channelId == channelId &&
        other.position == position &&
        other.duration == duration &&
        other.lastPlayedAt == lastPlayedAt &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return videoId.hashCode ^
        channelId.hashCode ^
        position.hashCode ^
        duration.hashCode ^
        lastPlayedAt.hashCode ^
        isCompleted.hashCode;
  }

  @override
  String toString() {
    return 'PlaybackPosition(videoId: $videoId, channelId: $channelId, position: $position, duration: $duration, lastPlayedAt: $lastPlayedAt, isCompleted: $isCompleted, watchPercentage: $watchPercentage)';
  }
}
