require 'ostruct'

class WeatherService
  CURRENT_FIELDS = ["temp_f", "wind_mph", "wind_dir", "humidity", "feelslike_f", "windchill_f"]
  FORECAST_FIELDS = ["maxtemp_f", "mintemp_f", "totalprecip_in", "daily_will_it_rain", "daily_will_it_snow"]

  def initialize(location_api, forecast_api)
    @location_api = location_api
    @forecast_api = forecast_api
  end

  def current_with_forecast(address)
    location = @location_api.lat_lon_for address
    raw = @forecast_api.fetch(location.lat, location.lon)

    current = raw["current"].slice(*CURRENT_FIELDS)
    current = OpenStruct.new(current)

    forecasts = raw["forecast"]["forecastday"].each_with_object({}) do |day, result|
      forecast = day["day"].slice(*FORECAST_FIELDS)
      result[day["date"]] = OpenStruct.new(forecast)
    end

    {current: current, forecast: forecasts}
  end
end
