# Description:
#   Reporting for climbing conditions
#
# Commands:
#   climb <location> - Returns information about climbing conditions for the requested location. If no location is provided, provides a general climbing recommendation.

# -- Climbing locations

RUMNEY =
  id: 'rumney',
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
  weatherCom.replace(/{ZIP}/, location.zip)

# Forecast.io
forecastIoApi =
    'https://api.forecast.io/forecast/30059f5ccc521da2292979482d428572/{LATLNG}'

forecastIoLines = 'http://forecast.io/lines/?q={LATLNG}'

forecastIoWidget =
    '<iframe id="forecast_embed" type="text/html" ' +
    'frameborder="0" height="245" width="100%" ' +
    'src="http://forecast.io/embed/#lat={LAT}&lon={LNG}&name={NAME}">' +
    '</iframe>'

# Gets weather recommendation from the forecast.io API.
#   {Object} location
getForecastIo = (location) ->
  #forecastIoApi.replace(/{LATLNG}/, location.latlng)
  forecastIoLines.replace(/{LATLNG}/, location.latlng)

# Establish a fixed endpoint at /climb/<location_id>
makeEndpointForLocation = (robot, location) ->
  @location = location
  @latlng = location.latlng.split(',')

  callback = (req, res) ->
    res.set 'Content-Type', 'text/html'
    res.send forecastIoWidget
        .replace(/{NAME}/, @location.name)
        .replace(/{LAT}/, @latlng[0])
        .replace(/{LNG}/, @latlng[1])

  robot.logger.info 'Making endpoint /climb/' + location.id
  robot.router.post '/climb/' + location.id, callback
  robot.router.get '/climb/' + location.id, callback


# -- Request handling

module.exports = (robot) ->
  makeEndpointForLocation(robot, RUMNEY)

  robot.hear /^climb( .*)?/i, (res) ->
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

    res.send 'Fetching climbing conditions for: ' + location.name
    res.send getAccuWeather(location)
    res.send getWeatherCom(location)
    res.send getForecastIo(location)


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
