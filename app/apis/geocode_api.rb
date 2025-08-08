class GeocodeApi
  API_KEY = Rails.application.credentials.geocode_api_key!
  URL = "https://geocode.maps.co/search"

  LatLon = Struct.new(:lat, :lon)

  def self.lat_lon_for(address)
    location_data = location(address)

    LatLon.new(location_data["lat"].to_f, location_data["lon"].to_f)
  end

  def self.location(address)
    request = HTTP.get(URL, params: {q: address, api_key: API_KEY})
    raw = request.to_s

    # We just need 'a' location. Best guess to match.
    JSON.parse(raw).first
  end
end
