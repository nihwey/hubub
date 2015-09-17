# Description:
#   Reporting for climbing conditions
#
# Commands:
#   climb <location> - Returns information about climbing conditions for the requested location. If no location is provided, provides a general climbing recommendation.

# -- Climbing locations

RUMNEY =
  name: 'Rumney',
  latlng: '43.8021,-71.8367',
  query: 'rumney nh',
  zip: '03266'


# -- Sources

# AccuWeather.com
accuweather =
    'http://www.accuweather.com/en/us/{QUERY}/{ZIP}/{MONTH_NAME}-weather/2174610'

# Gets weather recommendation from AccuWeather.
#   {Object} location
getAccuWeather = (location) ->
  date = new Date()
  accuweather
      .replace(/{QUERY}/, location.query.replace(' ', '-'))
      .replace(/{ZIP}/, location.zip)
      .replace(/{MONTH_NAME}/, getReadableMonth(date))

# Weather.com
weatherCom = 'http://www.weather.com/weather/monthly/l/{ZIP}:4:US'

# Gets weather recommendation from Weather.com.
#   {Object} location
getWeatherCom = (location) ->
  weatherCom
      .replace(/{ZIP}/, location.zip)

 # Forecast.io
forecastIo =
    'https://api.forecast.io/forecast/30059f5ccc521da2292979482d428572/{LATLNG}'

# Gets weather recommendation from forecast.io.
#   {Object} location
getForecastIo = (location) ->
  forecastIo
      .replace(/{LATLNG}/, location.latlng)


# Gets climbing information for the location from all known sources.
getClimbingInfo = (res, location) ->
  res.send 'Fetching climbing conditions for: ' + location.name
  res.send getAccuWeather(location)
  res.send getWeatherCom(location)
  res.send getForecastIo(location)


# -- Request handling

module.exports = (robot) ->
  robot.hear /climb( .*)?/i, (res) ->
    locationMatch =
        if res.match[1]? then res.match[1].trim().toLowerCase() else 'recommend'

    switch locationMatch
      when 'rumney'
        location = RUMNEY
      when 'red river gorge', 'rrg', 'red'
        res.send 'Recommendation for this location isn\'t implemented yet.'
        return
      when 'recommend'
        res.send 'Climbing recommendation hasn\'t been implemented yet.'
        return
      else
        res.send 'Unknown location request... try RUMNEY'
        return

    getClimbingInfo(res, location)


# -- Utilities

getReadableMonth = (date) ->
  switch date.getMonth()
    when 0
      return 'january'
    when 1
      return 'february'
    when 2
      return 'march'
    when 3
      return 'april'
    when 4
      return 'may'
    when 5
      return 'june'
    when 6
      return 'july'
    when 7
      return 'august'
    when 8
      return 'september'
    when 9
      return 'october'
    when 10
      return 'november'
    when 11
      return 'december'
