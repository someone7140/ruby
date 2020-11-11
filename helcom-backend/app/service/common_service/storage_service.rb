# frozen_string_literal: true

require 'google/cloud/storage'

module CommonService
  # GCSのストレージ管理サービス
  class StorageService
    # アイコン画像のアップロードしてURl取得
    def self.update_icon_image_file(user_id, image_file, before_image_file_url)
      if !user_id.nil? && !image_file.nil?
        # ファイル名の取得
        file_name = generate_icon_file_name(user_id, image_file.content_type)
        # バケットの取得
        bucket = get_bucket
        unless before_image_file_url.nil?
          before_image_file_name = get_file_name_from_url(before_image_file_url)
          # 既存ファイルの削除
          delete_image_file(before_image_file_name, bucket)
        end
        # アップロード
        file = bucket.create_file(image_file.tempfile, Rails.application.config.helcom.gcs_icon_path + file_name)
        file.public_url
      end
    end

    # ユーザIDとファイルのcontent_typeからアイコン画像用ファイル名を取得
    def self.generate_icon_file_name(user_id, content_type)
      if content_type.index('image/').zero?
        ext = content_type.gsub!('image/', '')
        user_id + '.' + ext
      end
    end

    def self.get_file_name_from_url(url)
      slash_last_index = url.rindex('/')
      url.slice(slash_last_index + 1, url.length - slash_last_index - 1)
    end

    # URLを指定してファイルを削除
    def self.delete_image_file_by_url(file_url)
      # バケットの取得
      bucket = get_bucket
      # ファイル名の取得
      image_file_name = get_file_name_from_url(file_url)
      # ファイルの削除
      delete_image_file(image_file_name, bucket)
    end

    # ファイル名を指定してファイルを削除
    def self.delete_image_file(file_name, input_bucket)
      unless file_name.nil?
        bucket = input_bucket.nil? ? get_bucket : input_bucket
        file = bucket.file(Rails.application.config.helcom.gcs_icon_path + file_name)
        file&.delete
      end
    end

    def self.get_bucket
      storage = Google::Cloud::Storage.new(
        project_id: Rails.application.config.helcom.gcs_project_id,
        credentials: Rails.application.config.helcom.gcs_credential_path
      )
      storage.bucket Rails.application.config.helcom.gcs_bucket
    end
  end
end
