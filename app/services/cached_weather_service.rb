class CachedWeatherService
  RETENTION_PERIOD = 30.minutes

  def initialize(location_api, forecast_api)
    @weather = WeatherService.new(location_api, forecast_api)
  end

  def current_with_forecast(address)
    Rails.cache.fetch(address, expires_in: RETENTION_PERIOD, skip_nil: true) do
      result = @weather.current_with_forecast(address)
      result.merge(fetched_at: Time.current.to_i)
    end
  end
end
