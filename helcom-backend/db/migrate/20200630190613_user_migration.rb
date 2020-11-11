# frozen_string_literal: true

# ユーザのマイグレーション
class UserMigration < Mongoid::Migration
  include MasterConstants
  include UserConstants
  include UserInfo
  def self.up
    User.create_indexes
    # 管理者ユーザの作成
    User.create!(
      _id: 'helcom_admin',
      email: 'admin@helcom.org',
      status: STATUS_ACTIVE,
      role: ROLE_ADMIN,
      password: 'HelcomPass',
      profile: {
        name: 'HELCOM管理者',
        sickness: 'none'
      }
    )
  end

  def self.down; end
end
