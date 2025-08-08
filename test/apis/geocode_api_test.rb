require "test_helper"

class GeocodeApiTest < ActiveSupport::TestCase
  test "lat_lon_for works for an address" do
    VCR.use_cassette("geocode_api_address") do
      address = "123 Madison St., Oak Park, Illinois"
      result = GeocodeApi.lat_lon_for(address)

      assert_in_delta result.lat, 41.88, 0.1
      assert_in_delta result.lon, -87.79, 0.1
    end
  end

  test "lat_lon_for works for a US zip code" do
    VCR.use_cassette("geocode_api_zip_code") do
      address = "60302"
      result = GeocodeApi.lat_lon_for(address)

      assert_in_delta result.lat, 41.88, 0.1
      assert_in_delta result.lon, -87.79, 0.1
    end
  end

  test "location works" do
    VCR.use_cassette("geocode_api_zip_code") do
      result = GeocodeApi.location("60302")

      assert_equal result["lat"], "41.89527719877642"
      assert_equal result["lon"], "-87.7852254403782"
    end
  end
end
