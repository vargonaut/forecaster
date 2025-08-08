require "test_helper"

class WeatherControllerTest < ActionDispatch::IntegrationTest
  test "should get show without an address" do
    get weather_show_url
    assert_response :success
  end

  test "should get show with an address" do
    VCR.use_cassette("weather_controller_zip") do
      get weather_show_url, params: { address: "60438" }
      assert_response :success
    end
  end
end
