http = require "request"
spec = require "tape"
sockjs = require "sockjs-client"
connect = require "rds-client"

SONNE = "http://pi.sonnenstreifen.de"
head = {headers: 'Content-Type': 'application/x-www-form-urlencoded'}
API = () -> sockjs SONNE + ":5000/sockjs", { 'force new connection': true }

spec "PUBLISH RIDE", (s) ->
  s.test "authorized post should notify rds", (t) ->
    t.plan 1
    rds = connect API(), () ->
      console.log "connected session=" + rds.token()
      rds.query route: "/Berlin/Munich"
      rds.on (ride) ->
        if ride.me
          console.log "found SELF"
          http.post SONNE + "/auth/ride/create", head, (err, res, body) ->
            console.log "response: " + body
            t.ok false, "missing response"
            rds.close()
          .write dummyRide()
        else
          console.log "found " + JSON.stringify ride



dummyRide = (r) ->
  ride = guid: "HiMo", origin: "Berlin", destination: "Munich"
  ride[k] = v for k, v of r if r
  #JSON.stringify ride
  body = ""
  body += (k + "=" + encodeURI(v) + "&") for k, v of ride
  body.slice 0, -1
