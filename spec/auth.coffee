http = require "request"
spec = require "tape"

URL = "http://pi.sonnenstreifen.de/auth/"
head = {headers: 'Content-Type': 'application/x-www-form-urlencoded'}

spec "POST RIDE", (s) ->

  s.test "respond Bad Request if no ride", (t) ->
    http.post URL + "ride/create", (err, res, body) ->
      t.equal res.statusCode, 400, "status code 400 " + body
      t.end()

  s.test "respond Unauthorized if no contact", (t) ->
    http.post URL + "ride/create", head, (err, res, body) ->
      r = JSON.parse body
      t.equal res.statusCode, 401, "status code 401 " + body
      t.equal r.details, "You must at least provide an email"
      t.end()
    .write dummyRide()

  s.test "respond Accepted if unknown email", (t) ->
    http.post URL + "ride/create", head, (err, res, body) ->
      t.equal res.statusCode, 202, "status code 202 " + body
      t.end()
    .write dummyRide email: "newbee42@sonnenstreifen.de"

  s.test "respond Payment Required known email", (t) ->
    http.post URL + "ride/create", head, (err, res, body) ->
      t.equal res.statusCode, 402, "status code 402 " + body
      t.end()
    .write dummyRide email: "regul@a.rr"


dummyRide = (r) ->
  ride = guid: "HiMo", origin: "Berlin", destination: "Munich"
  ride[k] = v for k, v of r if r
  #JSON.stringify ride
  body = ""
  body += (k + "=" + encodeURI(v) + "&") for k, v of ride
  body.slice 0, -1
