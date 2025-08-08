require "test_helper"

class WeatherServiceTest < ActiveSupport::TestCase
  def service
    @_weather_service ||= WeatherService.new(MockWeatherApis::Location, MockWeatherApis::Forecast)
  end

  test "current weather data is returned" do
    result = service.current_with_forecast(:address)
    current = result[:current]

    assert_equal "temp_f", current.temp_f
  end

  test "expected forecasts are returned" do
    result = service.current_with_forecast(:address)
    forecasts = result[:forecast]

    assert_equal 1, forecasts.count

    forecast = forecasts["January 1, 2024"]
    assert_equal "maxtemp_f", forecast.maxtemp_f
  end
end
