request = require 'request'
_ = require 'lodash'
async = require 'async'

deputy =
  companyID: 1
  employeeRoleID: 50
  baseEmail: 'kajute@kajute.com'
  api:
    json: true
    headers:
      Authorization: "OAuth #{process.env.DEPUTY_TOKEN}"

nb =
  tag: 'Will: Polling Day'

aliasEmail = (email) ->
  escapedEmail = deputy.baseEmail.replace('@', '_AT_')
    .replace(/\+/g, '_PLUS_', 'g')
  deputy.baseEmail.replace '@', "+#{escapedEmail}@"

createDeputyUser = (user, cb) ->
  deputyUser =
    intCompanyId: deputy.companyID
    strFirstName: user.first_name
    strLastName: user.last_name
    strEmail: aliasEmail(user.email)
    intRoleId: deputy.employeeRoleID
    strMobilePhone: user.mobile
  url = 'https://ellensandell.au.deputy.com/api/v1/addemployee'
  request.post _.merge(deputy.api, uri: url, json: deputyUser), cb

getNBUsers = (cb) ->
  url = "https://melbourne.nationbuilder.com/api/v1/tags/#{encodeURIComponent(nb.tag)}/people?per_page=30&#{process.env.NATIONBUILDER_TOKEN}"
  request.get uri: url, json: true, (err, res, json) ->
    if err then return cb err
    if res.statusCode is not 200 then cb 'Error status code from NB'
    cb null, json.results

exports.sync = (cb) ->
  getNBUsers (err, people) ->
    if err then return cb err
    async.eachSeries people, createDeputyUser, cb
