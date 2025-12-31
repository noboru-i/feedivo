import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';

/// UserエンティティのData層モデル
/// FirebaseのUserオブジェクトとDomain層のUserエンティティを相互変換
class UserModel {
  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  /// Firebase UserからUserModelを作成
  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'ユーザー',
      photoUrl: firebaseUser.photoURL,
    );
  }

  /// FirestoreのドキュメントからUserModelを作成
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  /// Domain層のUserエンティティからUserModelを作成
  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    );
  }
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;

  /// Firestoreに保存するためのMapに変換
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  /// Domain層のUserエンティティに変換
  User toEntity() {
    return User(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
