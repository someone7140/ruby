# frozen_string_literal: true

# UserAccountコレクションのリポジトリ
class UserAccountRepository
  def self.get_user_account_by_gmail(gmail)
    UserAccount.find_by(gmail:)
  end

  def self.create_user_account_by_gmail(id, gmail, email, password)
    user_account = UserAccount.new(
      _id: id,
      gmail:,
      email:,
      password:
    )
    user_account.save!
    user_account
  end
end
