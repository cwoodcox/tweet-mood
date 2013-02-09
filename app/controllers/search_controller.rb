class SearchController < ApplicationController
  def index

  end

  def search
    city_1_geo = Twitter.geo_search(query: params[:search][:city_1], granularity: 'city')
    city_1_geo = city_1_geo.first.bounding_box.coordinates.first.collect(&:reverse) # Why do these come in such tiny boxes and BACKWARDS?
    city_1_gem = city_1_geo.reduce
    city_1_tweets = Twitter.search(params[:search][:query], geocode: city_1_geo).collect(&:statuses).collect(&:text)
    city_2_tweets = Twitter.search(params[:search][:query], geocode: city_2_geo).collect(&:statuses).collect(&:text)
  end
end
