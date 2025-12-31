/// ユーザーエンティティ
/// ドメイン層のビジネスロジックで使用する純粋なDartオブジェクト
class User {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        (photoUrl?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl)';
  }
}
