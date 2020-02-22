class NewsController < ApplicationController
  def list
    render json: NewsService::getNews(params[:category], params[:word])
  end
end
