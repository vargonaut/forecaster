 It will get the current conditions and forecast for an address or zip code.

This is meant to be an exploration of ideas and architecture. Its currently not suitable to 'just use'.

# Requirements

This application uses Ruby `3.4.5`. It uses Rails `8`.  Any Unix-like environment with those should work.


As far as environment, there is nothing exotic.

# Setup

## API Keys

Two APIs are used in the application. Geocoding is used to get a lat/lon and the Weather fetches forecasts.

### Geocoding

[Geocoding API](https://geocode.maps.co/) is used for geocoding.

Sign up for a key, and add it to the application credentials.

    EDITOR="code --wait"  bin/rails credentials:edit

    geocode_api_key: YOUR_KEY

### Forecasting

[Weather API](https://www.weatherapi.com/) is used for forecasting.

Sign up for a key, and add it to the application credentials.

    EDITOR="code --wait"  bin/rails credentials:edit

    forecast_api_key: YOUR_KEY

## Database

`ActiveRecord` is not in use. However, caching for development is a `sqlite` database.

Proper set up and choices for production need be made.

## Enable Caching

Caching is not turn on by default locally. Enable it with:

   bin/rails dev:cache


# Tests

Run test with `bin/rails test`

`VCR` is used for network calls. API keys are filtered before storage.

# Deployment

TBD - target infrastructure unknown.

Caching needs to be in place for a distributed environment. See [caching] for more details on what is required.

# Design and Choices

This is discussion of how the application works, trade offs considered and look at some internals.

## Overview

The application current has a single page for requesting and displaying weather.

A user provides an address.  The controller readies a service and uses it to fetch the data.

The `cached` service is just a wrapper around the action service. It handles retention and cache keys.

The actual service will look up the address via geocoding. The lat/lon from that will be use to fetch weather.

Weather in hand, the controller gets it ready and the view shows the results.

### APIs

A directory for the APIs has been created. This was to signal that these need network access.

#### `Geocodeapi`

`location` will make the geocode request. We only require an address. We are not concerned with deep choices, so simply take the first one provided. The API does not allow us to limit it.

`lat_lon_for` is the real workhorse of the API.  It fetches the `location` and pull out the lat/lon.

`LatLon` is a struct for returning the attributes. This makes it easier to use upstream.



Other APIs were looked at. This one was genuinely free with a sign up and very easy to use.

There is a hidden difficult here, in that ZIP codes are hard to get if you do not have them.

#### `ForecastApi`

`fetch` hits the API for the current conditions and 3 days of forecasts.

The days of forecast was chosen arbitrarily and can bet set with `FORECAST_DAYS`.

#### Tradeoffs

Geocoding was a struggle. Ideally, with the requirements, we want to cache by ZIP.  There is not a clear way to get one from an address. Or there is, but it would mean an additional API or attempting to parse. Parsing was considered and rejected from time constraints. Its likely to be thicket.

Forecast APIs all seem to need a lat/lon.  Some have a separate geocoding API, but all needed a credit card or something. The one chose is good enough on the free tier.

### Services

#### `WeatherService`

Weather service requires a location and forecast API. It handles the
setup calls and data aggregation. A sort of controller away from the
controller.

Weather comes as `current` and `forecast`. The desired fields (using a constant) are pulled from the raw data and assembled into a hash for upstream.

The individual results are put into a struct. I'd prefer a formal object, but this worked well. It'd require 2 objects, which seems a bit overkill at this point.

The forecasts are assembled under a `day` key.

    {
        current: current_struct,
        forecasts: {
            day: forecast_struct,
            ...
        }
    }


#### `CachedWeatherService`

This is a thin wrapper around `WeatherService` to allow caching results.

The retention period for caching is 30 minutes, set via `RETENTION_PERIOD`.

It also adds an additional field to the results: `fetched_at`. Instead of checking the cache first, we just use a date. Its easier and allows us to compute data freshness over cached or not.

The `cache key` is a concern. `address` was chosen for simplicity, but we're likely to get a ton of one off stuff in the cache. Clearly ideas what our goals and incoming data look like could lead to reform.


### Controllers

#### `WeatherController#show`

There is only the one action.

If no `address` param is provided, nothing will be set and the page will be show.

If we have an `address`, `CachedWeatherService` will be used to fetch the forecast and it'll be split into `@current_conditions`, `@forecast` and `@fetched_at`. Those all will drive the view.

The application is not very robust, so the controller has a catch all error grab. An errors are put into flash for end users to see.


### Views

#### `weather/show`

Most of the page is straight forward. It will display a greeting and form.

If the form is used, the weather results will also be show.

Instead of cached or not, `fetched_at` is used to show the age of the data.

The view could be cleaned up and broken down, but I find it fine for now. An agreement on view should be reached before further clean up.


# Caching

Caching is currently using the new Rails default of database backed.

Without knowing projected volume and production environment, its difficult to make a broader recommendation.

`redis` would work fantastic too, if its already in place.

The key of `address` is also much too broad unless we know folks will primarily use the app.

# General Discussion

This was a fun project and I enjoyed how it hit so many ideas in such a small application.  I did not realize how rusty I was getting a new application up and going!

APIs and caching were the surprising sticking points. There are not (cheap/free) APIs that did what I wanted. I was actually surprised they all require lat/lon.

That requirement interferes with caching. We'd like to cache by zip, but we'd have to parse that out or find an API that can do it. That would make 3 calls for a forecast!

The other option would be to do the best to parse out zip codes from the address. There lies madness, especially without knowing the business needs. Too many variants and we aren't guaranteed one.

I initially wanted to do `index` and `create` but walked back to `show`. It made me feel early career as I was trying to get it going right on a page. Rails has certainly locked things down more since last I was in that area.
