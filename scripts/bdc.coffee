# Description:
#   Provides information about dance classes around NYC.

module.exports = (robot) ->
  # Provide a link to the Broadway Dance Center daily schedule.
  robot.hear /BDC/i, (res) ->
    url = 'http://www.broadwaydancecenter.com/schedule/{MONTH}_{DATE}.shtml'
    today = new Date()
    res.send url
        .replace(/{MONTH}/, today.getMonth() + 1)
        .replace(/{DATE}/, today.getDate())
