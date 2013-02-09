class SearchController < ApplicationController
  def index

  end

  def search
    city_1 = Twitter.geo_search(query: params[:search][:city_1], granularity: 'city')
    city_1_geo = average_square get_coords(city_1)

    city_2 = Twitter.geo_search(query: params[:search][:city_2], granularity: 'city')
    city_2_geo = average_square get_coords(city_2)

    city_1_tweets = Twitter.search(params[:search][:query], geocode: city_1_geo.join(',') + ",25mi").statuses.collect(&:text)
    city_2_tweets = Twitter.search(params[:search][:query], geocode: city_2_geo.join(',') + ",25mi").statuses.collect(&:text)

    @city_1_sentiments = city_1_tweets.collect do |tweet|
      AlchemyAPI.search :sentiment_analysis, text: tweet
    end

    @city_2_sentiments = city_2_tweets.collect do |tweet|
      AlchemyAPI.search :sentiment_analysis, text: tweet
    end
  end

  def average_square array
    array.reduce([]) do |ret, coords|
      ret = [coords[0] + ret[0].to_f, coords[1] + ret[1].to_f]
    end.collect do |coords|
      coords / array.length
    end
  end

  def get_coords array
    # Why do these come in such tiny boxes and BACKWARDS?
    array.first.bounding_box.coordinates.first.collect(&:reverse)
  end
end
