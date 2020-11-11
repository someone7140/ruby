# frozen_string_literal: true

module UserInfo
  # Profile
  class Profile
    include MasterConstants
    include Mongoid::Document

    field :name, type: String
    field :image_url, type: String
    field :sickness, type: String
    field :talking_sickness, type: String
    field :introduction, type: String
    field :purpose, type: String
    field :twitter_url, type: String
    field :instagram_url, type: String
    field :facebook_url, type: String
    embedded_in :user
    validates :name, presence: true
    validates :sickness, presence: true, inclusion: { in: PROFILE_DISEASE_LIST.map { |d| d[:key] } }
    validates :talking_sickness, inclusion: { in: [nil] + PROFILE_DISEASE_LIST.map { |d| d[:key] } }
  end
end
