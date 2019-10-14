class Initial < Mongoid::Migration
  def self.up
    # ID管理
    IdManage.create(key: Constants::USER_ID_KEY, value: 0)
    IdManage.create_indexes
    # ユーザ
    time = Time.now
    User.create(_id: 0, name: 'admin', email: 'admin@example.com', password: 'password', created_at: time, updated_at: time)
    User.create_indexes
  end

  def self.down
  end
end