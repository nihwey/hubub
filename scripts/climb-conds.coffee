# Description:
#   Reporting for climbing conditions
#
# Commands:
#   climb <location> - Returns information about climbing conditions for the requested location. If no location is provided, provides a general climbing recommendation.

# -- Climbing locations

RED_RIVER_GORGE =
  id: 'rrg',
  name: 'Red River Gorge',
  latlng: '37.7842, -83.6824',
  query: 'slade ky',
  zip: '40376',
  accuweatherId: '2194984'

RUMNEY =
  id: 'rumney',
  name: 'Rumney',
  latlng: '43.8021,-71.8367',
  query: 'rumney nh',
  zip: '03266',
  accuweatherId: '2174610'

LOCATIONS = [
  RED_RIVER_GORGE,
  RUMNEY
]

# -- Sources

# AccuWeather.com
accuweather =
    'http://www.accuweather.com/en/us/{QUERY}/{ZIP}/{MONTH_NAME}-weather/' +
    '{ACCUWEATHER_ID}'

# Gets weather recommendation from AccuWeather.
#   {Object} location
getAccuWeather = (location) ->
  date = new Date()
  accuweather
      .replace(/{QUERY}/, location.query.replace(' ', '-'))
      .replace(/{ZIP}/, location.zip)
      .replace(/{MONTH_NAME}/, getReadableMonth(date))
      .replace(/{ACCUWEATHER_ID}/, location.accuweatherId)

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
    'style="border-bottom:1px solid black" ' +
    'src="http://forecast.io/embed/#lat={LAT}&lon={LNG}&name={NAME}">' +
    '</iframe>'

# Gets weather recommendation from the forecast.io API.
#   {Object} location
getForecastIo = (location) ->
  #forecastIoApi.replace(/{LATLNG}/, location.latlng)
  # NOTE: This is buggy; they seem to persist some amount of data (in cookies?)
  # so it remembers the first location you went to and always shows that data
  # no matter the &q.
  forecastIoLines.replace(/{LATLNG}/, location.latlng)

makeLinkElement = (url, linkText) ->
  '<a href="' + url + '">' + linkText + '</a>'

# Establish a fixed endpoint at /climb/<location_id>
makeEndpointForLocation = (robot, location) ->
  callback = (req, res) ->
    [lat, lng] = location.latlng.split(',')

    page = '<style>' +
      'a {' +
        'display:inline-block;' +
        'font-family: sans-serif;' +
        'padding: 20px;' +
        'text-decoration: none;' +
      '}' +
    '</style>'
    page += forecastIoWidget
        .replace(/{NAME}/, location.name)
        .replace(/{LAT}/, lat)
        .replace(/{LNG}/, lng)
    page += makeLinkElement(getForecastIo(location), 'Forecast.io Lines')
    page += makeLinkElement(getAccuWeather(location), 'AccuWeather.com')
    page += makeLinkElement(getWeatherCom(location), 'Weather.com')

    res.set 'Content-Type', 'text/html'
    res.send page

  robot.logger.info 'Making endpoint /climb/' + location.id
  robot.router.post '/climb/' + location.id, callback
  robot.router.get '/climb/' + location.id, callback


# -- Request handling

module.exports = (robot) ->
  makeEndpointForLocation(robot, location) for location in LOCATIONS

  robot.hear /climb( .*)?/i, (res) ->
    locationMatch =
        if res.match[1]? then res.match[1].trim().toLowerCase() else 'any'

    switch locationMatch
      when 'rumney'
        location = RUMNEY
      when 'red river gorge', 'rrg', 'red'
        location = RED_RIVER_GORGE
      else
        res.send 'mmm climbing ^___^'
        return

    res.send 'http://hubub.herokuapp.com/climb/' + location.id


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
