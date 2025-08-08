class ForecastApi
  API_KEY = Rails.application.credentials.forecast_api_key!
  FORECAST_DAYS = 3

  URL = "http://api.weatherapi.com/v1/forecast.json"

  def self.fetch(lat, lon)
    request = HTTP.get(URL, params: {q: "#{lat}, #{lon}", days: FORECAST_DAYS, key: API_KEY})
    raw = request.to_s

    _forecast = JSON.parse(raw)
  end
end
