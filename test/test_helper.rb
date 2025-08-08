ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require 'ostruct'

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock

  config.filter_sensitive_data("[GEOCODE_API_KEY]") { Rails.application.credentials.geocode_api_key }
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end


module MockWeatherApis
  class Location
    def self.lat_lon_for(_address)
      OpenStruct.new(lat: 123, lon: 567)
    end
  end

  class Forecast
    def self.fetch(_lat, _lon)
      {"current" => current, "forecast" => forecast}
    end

    def self.current
      WeatherService::CURRENT_FIELDS.to_h{ |key| [key, key] }
    end

    def self.forecast
      forecast_hash = WeatherService::FORECAST_FIELDS.to_h{ |key| [key, key] }
      {
        "forecastday"=> [{
                          "date" => "January 1, 2024",
                          "day" => forecast_hash
                          }]
      }
    end
  end
end
