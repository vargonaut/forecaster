require "test_helper"

class FetchWeatherTest < ActionDispatch::IntegrationTest
  test "loads fine without an address" do
    get "/weather/show"

    assert_dom "h1", "Weather Forecaster"
  end

  test "loads fine with an address" do
    VCR.use_cassette("fetch_weather_integration_test") do
      get "/weather/show", params: { address: "02144" }

      assert_dom "p", "Fetched less than a minute ago."

    end
  end

  test "shows the current weather" do
    VCR.use_cassette("fetch_weather_integration_test") do
      get "/weather/show", params: { address: "02144" }

      assert_dom "h3", "Current Conditions"
    end
  end

  test "shows the forecasts" do
    VCR.use_cassette("fetch_weather_integration_test") do
      get "/weather/show", params: { address: "02144" }

      assert_dom "h3", "Forecasts"
    end
  end
end
