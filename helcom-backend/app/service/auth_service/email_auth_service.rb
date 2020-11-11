# frozen_string_literal: true

require 'bcrypt'

module AuthService
  # メール認証用のサービス
  class EmailAuthService
    include BCrypt
    include CommonService
    include UserConstants
    include UserInfo

    # email認証用登録のユーザを取得
    def self.get_regist_email_user(id, email, password)
      # 1日後の日付
      now_plus_one_day = DateService.get_plus_now_day(1)
      # tokenの生成
      token = GenerateService.generate_token(32)
      # ユーザmodelのvalidate
      new_user = User.new(
        _id: id,
        email: email,
        password: password,
        status: STATUS_CONFIRMING,
        role: ROLE_USER,
        email_auth_info: {
          temp_email: email,
          token: token,
          expired_at: now_plus_one_day
        }
      )
      # modelのチェック
      return nil unless new_user.valid?

      # メールアドレス・パスワードチェック（ユーザmodelにvalidate記載していない部分）
      if (email.blank? || !email_format_check(email)) ||
         (password.nil? || password.length < 6)
        return nil
      end

      # レコード存在チェック
      exist_users = User.where('$or' => [{ _id: id }, { email: email }])
      if exist_users.length.positive?
        exist_user = exist_users[0]
        # ステータスが確認中かつメールアドレスが同じ場合は削除
        if exist_user.status == STATUS_CONFIRMING && exist_user.email == email
          exist_user.delete
        else
          return nil
        end
      end
      new_user
    end

    # emailの変更登録
    def self.email_change_and_return_token(user_id, new_email)
      # レコード存在チェック
      exist_users = User.where(email: new_email)
      if exist_users.length.positive?
        nil
      else
        user_collection = User.get_user_collection
        token = GenerateService.generate_token(32)
        user_collection.update_one(
          { '_id' => user_id },
          { '$set' => {
            'email_auth_info' => {
              temp_email: new_email,
              token: token,
              expired_at: DateService.get_plus_now_day(1)
            }
          } }
        )
        token
      end
    end

    # email認証に問題ないかチェックしてOKだったらuserを返す
    def self.get_authenticated_email_user(user_id, token, password)
      # blank判定
      return nil if user_id.blank? || token.blank? || password.blank?

      user = User.find(user_id)
      # userが取得できなかったらnilを返す
      return nil if user.nil?
      # パスワードチェック
      return nil unless user.authenticate(password)
      # ステータスチェック
      return nil if user.status != STATUS_CONFIRMING
      # tokenチェック
      return nil if user.email_auth_info.token != token
      # token期限チェック
      return nil if user.email_auth_info.expired_at < Time.now.utc

      # ユーザのステータス更新
      user.status = STATUS_ACTIVE
      # email認証情報を空にする
      user.email_auth_info = nil
      user
    end

    # email変更認証
    def self.email_change_authentication(user_id, token, password)
      # blank判定
      return false if user_id.blank? || token.blank? || password.blank?

      get_user = User.where(_id: user_id).only(
        :_id,
        :password_digest,
        'email_auth_info.temp_email',
        'email_auth_info.token',
        'email_auth_info.expired_at'
      )
      # userが取得できなかったらnilを返す
      return false if get_user.empty?

      user = get_user[0]
      # パスワードチェック
      return false unless user.authenticate(password)
      # tokenチェック
      return false if user.email_auth_info.token != token
      # token期限チェック
      return false if user.email_auth_info.expired_at < Time.now.utc

      # email変更＆email認証情報を空にする
      user_collection = User.get_user_collection
      user_collection.update_one(
        { '_id' => user_id },
        {
          '$set' => {
            'email' => user.email_auth_info.temp_email
          },
          '$unset' => {
            'email_auth_info' => ''
          }
        }
      )
      true
    end

    # emailから認証用にユーザを取得
    def self.get_user_by_email(email)
      # eメールのブランクチェック
      return nil if email.blank?

      # eメールからユーザを取得
      find_by_email_user = User.where(email: email).only(
        :_id,
        :password_digest,
        :status,
        :role,
        :login_count,
        'profile.name',
        'profile.image_url'
      )
      if find_by_email_user.empty?
        nil
      else
        find_by_email_user[0]
      end
    end

    # メールアドレスのフォーマットチェック
    def self.email_format_check(email)
      mail_regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      email.match? mail_regex
    end

    # パスワード変更
    def self.change_password(user_id, password)
      new_password_digest = Password.create(password)
      user_collection = User.get_user_collection
      user_collection.update_one(
        { '_id' => user_id },
        { '$set' => {
          'password_digest' => new_password_digest
        } }
      )
    end

    # パスワードリセット申請
    def self.send_password_reset(email)
      # ステータスがアクティブのユーザ
      user_find_result = User.where(email: email, status: STATUS_ACTIVE).only(
        :_id,
        :password_reset_info
      )
      pw_info = PasswordResetInfo.new(
        token: GenerateService.generate_token(32),
        expired_at: DateService.get_plus_now_day(1)
      )
      if !user_find_result.empty? && pw_info.valid?
        user_collection = User.get_user_collection
        registered_password_reset_info = user_find_result[0].password_reset_info
        # 既にパスワードリセット情報があれば削除
        unless registered_password_reset_info.nil?
          user_collection.update_one(
            { 'email' => email },
            { '$unset' => {
              'password_reset_info' => ''
            } }
          )
        end
        user_collection.update_one(
          { 'email' => email },
          { '$set' => {
            'password_reset_info' => {
              token: pw_info.token,
              expired_at: pw_info.expired_at
            }
          } }
        )
        {
          user_id: user_find_result[0]._id,
          token: pw_info.token
        }
      end
    end

    # パスワードリセット登録
    def self.regist_password_reset(user_id, token, password)
      user_find_result = User.where(_id: user_id, status: STATUS_ACTIVE).only(
        :_id,
        'password_reset_info.token',
        'password_reset_info.expired_at'
      )
      if !user_find_result.empty?
        pw_info = user_find_result[0].password_reset_info
        if !pw_info.nil? && pw_info.token == token && pw_info.expired_at >= Time.now.utc
          # パスワードを更新
          change_password(user_find_result[0]._id, password)
          # パスワードリセット情報を削除
          user_collection = User.get_user_collection
          user_collection.update_one(
            { '_id' => user_id },
            { '$unset' => {
              'password_reset_info' => ''
            } }
          )
          true
        else
          false
        end
      else
        false
      end
    end
  end
end
