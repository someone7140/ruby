# frozen_string_literal: true

module PostInfo
  # 記事のOGP情報
  class Ogp
    include Mongoid::Document
    field :site_name, type: String
    field :description, type: String
    field :image_url, type: String
  end
end
