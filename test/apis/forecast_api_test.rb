require "test_helper"

class ForecastApiTest < ActiveSupport::TestCase
  def get_forecast
    ForecastApi.fetch(41.9, -87.79)
  end

  test "current weather data is returned" do
    VCR.use_cassette("forecast_api_3_day_forecast") do
      forecast = get_forecast["current"]

      assert_equal 89.1, forecast["temp_f"]
      assert_equal 7.2, forecast["wind_mph"]
      assert_equal "SSW", forecast["wind_dir"]
      assert_equal 54, forecast["humidity"]
      assert_equal 94.5, forecast["feelslike_f"]
      assert_equal 89.1, forecast["windchill_f"]
    end
  end

  test "3 day forecast weather data is returned" do
    VCR.use_cassette("forecast_api_3_day_forecast") do
      forecast = get_forecast["forecast"]["forecastday"]

      assert_equal 3, forecast.length

      day_one_keys = forecast.first["day"].keys

      assert_includes day_one_keys, "maxtemp_f"
      assert_includes day_one_keys, "mintemp_f"
      assert_includes day_one_keys, "totalprecip_in"
      assert_includes day_one_keys, "daily_will_it_rain"
      assert_includes day_one_keys, "daily_will_it_snow"
    end
  end
end
