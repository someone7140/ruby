# ローカル環境構築

## 前提

- Mac での環境構築手順を記載しています。Windows の場合は適宜読みかえてご対応ください。
- Rails6・Ruby バージョン 2.7.1 を前提としてます。  
  Ryby のバージョンの更新については[Mac での Ruby 環境構築 2020](https://qiita.com/chihiro/items/efdf8b88865b7a93971f)を参考にしてください。
- MongoDB を使用しています。[brew から mongodb がなくなったので mongodb-community をインストールする](https://qiita.com/kazuki5555/items/b80f1f313137dffbb351)を参考にインストールしてください。また、GUI ツールとして`MongoDB Compass`というものがあります。[MongoDB の GUI CRUD ツール：MongoDB Compass を使ってみた](https://dev.classmethod.jp/articles/introducing-mongodb-compass/)

## Rails 起動のための準備

- この`backend`フォルダ配下で`bundle install`を実行してください。Bundler については[Bundler の使い方](https://qiita.com/oshou/items/6283c2315dc7dd244aef)を参考にしてください。エラーが発生する場合は`gem update --system`、`xcode-select --install`を実行してみてください。なお、Gemfile が更新されている場合は再度`bundle install`を実行してください。また、VSCode でのデバッグについては[Visual Studio Code で Rails のリモートデバッグ](https://qiita.com/trantan/items/90933b91d78fbffe7123)を参考にしてください。

## MongoDB の設定

- インストールした MongoDB に`helcom_db`という名前のデータベースを作成してください。一つ目のコレクションは`sample`とか適当な名前で大丈夫です。
- `rails db:migrate`のコマンドを実行してください。これで DB のコレクション・初期データを作成します。

# その他

- コーディングスタイルのチェックには RuboCop を使用しています。詳細は[RuboCop でコーディングスタイルを矯正する
  ](http://momota.github.io/blog/2016/06/17/rubocop/)を参照してください。
- SendGrid のキーなど環境毎に設定が必要なものは`helcom_setting.yml`に設定しています。なお、ローカル環境や開発環境のアカウントは伊藤個人のものなので、使いすぎや他への流用は行わないようにしてください、発覚した場合は公開をストップします。できれば個人個人でアカウントを取得頂けると助かります。
- 画像管理用の GCS について、key ファイルは`config/google_cloud_storage`に設定、取得方法は[Google Cloud Platform のサービスアカウントキーを作成する](https://www.magellanic-clouds.com/blocks/guide/create-gcp-service-account-key/)を参考にしてください。使いすぎや他への流用が発覚した時点で公開をストップします。
- ログインが必須な API は class の定義に`before_action :logged_in_user`を追加してください。クラスのなかで一部メソッドに適用したい場合は`only`句で設定してください。
- 問合せのメール送付先は、ローカルと開発環境は伊藤の個人アドレスに設定しています。変更する場合は`helcom_setting.yml`の`inquiry_mail_address`を変更してください。
