# frozen_string_literal: true

# 環境毎の設定ファイルの読み込み
def appilication_load_config(key, filepath)
  yml = YAML.load_file(filepath).symbolize_keys
  raise "No such file #{filepath}" if yml.blank?

  config = yml[Rails.env.to_sym]
  raise "No such environment #{Rails.env} on #{filepath}" if config.blank?

  Rails.application.config.send("#{key}=", ActiveSupport::InheritableOptions.new(config.deep_symbolize_keys))
end

appilication_load_config(:helcom, Rails.root.join('config', 'helcom_setting.yml'))
