class SearchController < ApplicationController
  def index

  end

  def search
    city_1 = Twitter.geo_search(query: params[:search][:city_1], granularity: 'city').first
    city_1_geo = average_square get_coords(city_1)

    city_2 = Twitter.geo_search(query: params[:search][:city_2], granularity: 'city').first
    city_2_geo = average_square get_coords(city_2)

    city_1_tweets = Twitter.search(params[:search][:query], geocode: city_1_geo.join(',') + ",25mi").statuses.collect(&:text)
    city_2_tweets = Twitter.search(params[:search][:query], geocode: city_2_geo.join(',') + ",25mi").statuses.collect(&:text)

    @cities = [{ 'name' => city_1.name }, { 'name' => city_2.name }]

    @sentiments = {}
    @sentiments[city_1.name] = city_1_tweets.collect do |tweet|
      AlchemyAPI.search(:sentiment_analysis, text: tweet).merge({'text' => tweet})
    end

    @sentiments[city_2.name] = city_2_tweets.collect do |tweet|
      AlchemyAPI.search(:sentiment_analysis, text: tweet).merge({'text' => tweet})
    end

    @cities.first['overall'] = @sentiments[city_1.name].reduce(0) do |total,sentiment|
      total + sentiment['score'].to_f
    end / @sentiments[city_1.name].length

    render action: :index
  end

  def average_square array
    array.reduce([]) do |ret, coords|
      ret = [coords[0] + ret[0].to_f, coords[1] + ret[1].to_f]
    end.collect do |coords|
      coords / array.length
    end
  end

  def get_coords obj
    # Why do these come in such tiny boxes and BACKWARDS?
    obj.bounding_box.coordinates.first.collect(&:reverse)
  end
end
