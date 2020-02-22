class MasterController < ApplicationController
  def list
    render json: {
      status: ResponseConstants::HTTP_STATUS_200,
      data: {
        gender: MasterConstants::GENDER,
        school_categoty: MasterConstants::SCHOOL_CATEGORY,
        prefecture: MasterConstants::PREFECTURE,
        facebook_api: MasterConstants::FACEBOOK_API,
        news_category: MasterConstants::NEWS_CATEGORY
      }
    }
  end
end
