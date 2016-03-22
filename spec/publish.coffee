http = require "request"
spec = require "tape"
sockjs = require "sockjs-client"
connect = require "rds-client"

SONNE = "http://pi.sonnenstreifen.de"
head = {headers: 'Content-Type': 'application/x-www-form-urlencoded'}
API = () -> sockjs SONNE + ":5000/sockjs", { 'force new connection': true }

spec "PUBLISH RIDE", (s) ->
  s.test "authorized post should notify rds", (t) ->
    t.plan 2
    rds = connect API(), () ->
      console.log "connected session=" + rds.token()
      rds.query route: "/Berlin/Munich"
      rds.on (ride) ->
        if ride.me
          console.log "found SELF"
          http.post SONNE + "/auth/ride/update/HiMo/ec485a75040cb839157b7aae3fcde3950aeb745e128940cf2e4222b8be93b2e0", head, (err, res, body) ->
            console.log "response: " + body
            r = JSON.parse body
            t.equal res.statusCode, 200, "status code 200"
            t.equal r.details, "Ride successfully updated.", "Ride successfully updated."
            rds.close()
          .write dummyRide destination: "Hamburg"
        else
          console.log "found " + JSON.stringify ride



dummyRide = (r) ->
  ride = guid: "HiMo", origin: "Berlin", destination: "Munich"
  ride[k] = v for k, v of r if r
  #JSON.stringify ride
  body = ""
  body += (k + "=" + encodeURI(v) + "&") for k, v of ride
  body.slice 0, -1
