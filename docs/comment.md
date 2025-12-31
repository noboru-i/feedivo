## TODO 1
Firestoreのルール
VideoRepository.getVideos で channels を見ているが、これは何を格納しているか？
userIdを取得しているだけであれば、ログイン情報から取得できるので、不要なのではないか？

## TODO 2
URL pathのリストを作成してください。
また、パスとして定義されていない画面は、この際に定義して実装してください。

## TODO 3
google_sign_in のバージョンが古いので、最新化してください。

## TODO 4
path_provider, shared_preferences, timeago, url_launcher が不要なようなので、削除してください。
関連する不要なコードがあれば、それも合わせて削除してください。

## TODO 5
repository layerのinterfaceは、過度な抽象化なので不要です。
CLAUDE.mdなども含めて更新してください。

## TODO 6
チャンネルのJSONファイルに `videos` が無い場合、
そのJSONファイルと同一階層にあるmp4ファイルを再生対象としたいです。

## TODO 7
チャンネル設定ファイルフォーマットはdocs内の1つのファイルに集約して、
README.mdとCLAUDE.mdは、そちらへのリンクだけにしてください。（コンテキスト節約のため）
firestoreのデータ構造とセキュリティルールについても、同様に1つのファイルだけに集約してください。
「開発状況」も、過去のものとなったため、 implementation-history.md に残っていればOKです。

## TODO 8
drive.readonly から、 drive.file 権限の取得へ変更。
