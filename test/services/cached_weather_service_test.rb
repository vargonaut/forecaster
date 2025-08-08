require "test_helper"
require "minitest/mock"

class WeatherServiceTest < ActiveSupport::TestCase
  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache.lookup_store(:memory_store)
  end

  teardown do
    Rails.cache = @original_cache
  end

  def make_service
    location = MockWeatherApis::Location
    forecast = MockWeatherApis::Forecast
    CachedWeatherService.new(location, forecast)
  end

  test "calls are cached" do
    service = make_service
    address = "some address"
    assert_not Rails.cache.exist?(address)

    service.current_with_forecast(address)
    assert Rails.cache.exist?(address)
  end

  test "adds 'fetched_at'" do
    service = make_service

    result = service.current_with_forecast("123")
    assert_not_nil result[:fetched_at]
  end
end
