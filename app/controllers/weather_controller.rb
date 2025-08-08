class WeatherController < ApplicationController
  def show
    if params[:address]
      begin
        @address = params[:address]

        service = CachedWeatherService.new(GeocodeApi, ForecastApi)
        weather_data = service.current_with_forecast(@address)

        @current_conditions = weather_data[:current]
        @forecasts = weather_data[:forecast]
        @fetched_at = Time.at weather_data[:fetched_at]
      rescue => e
        flash.alert = e.message
      end
    end
  end
end
