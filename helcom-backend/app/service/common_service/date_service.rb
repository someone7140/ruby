# frozen_string_literal: true

module CommonService
  # 各種値の生成サービス
  class DateService
    def self.get_plus_now_day(plus_day)
      Time.now.utc + plus_day.days
    end
  end
end
