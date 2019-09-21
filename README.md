# dropcast
Dropboxにmp3とRSSファイルをアップロードして、Podcast配信できるようにするスクリプト。

## 環境
```bash
$ jq --version
jq-1.6
```

## 使い方
0. mp3フォルダに配信したいmp3ファイルを置く
0. dropcast.shの`DROPBOX_TOKEN`にDropbox API用のTOKENを設定
0. 必要に応じて`DROPBOX_BASEDIR`にDropbox上のアップロードフォルダ名を設定
0. `$ dropcast.sh -t title`を実行
0. 最後に標準出力されるアドレスをコピーして、Podcastクライアントに入力する
