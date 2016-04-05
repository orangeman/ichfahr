#ecstatic = require("ecstatic")(".", cache: "no-cache")
url = require("./src/urlify")()
es = require "event-stream"
http = require "http-proxy"
request = require "request"
connect = require "connect"
tralala = require "harmon"
detailshtml = require("fs").readFileSync("inc/html/details.html").toString()
rowhtml = require("fs").readFileSync("inc/html/row.html").toString()
JSONStream = require "JSONStream"
render = require "./src/render"
ip = require "geoip-resolve"

process.env.TZ = 'Europe/Amsterdam'
SONNE = "http://pi.sonnenstreifen.de"
proxy = http.createProxyServer()
FORWARD = SONNE + "/ichfahr/"
API = SONNE + ":5000"

# LOCAL TEST & DEVELOP SERVER
if process.argv[2] == "local"
  FORWARD = "http://localhost:1234/"
  require("http").createServer(
    require("ecstatic") "./",
    cache: "no-cache"
  ).listen 1234

# MIX AND MASH UP HTML
trompete = tralala [], [
  { query: "#from"
  func: (dom, req, res) ->
    console.log "FROM PLACE #{req.place}"
    dom.createWriteStream().end '<input value="' + req.place + '" type="text" class="form_inputtext fromto start_form_from" placeholder="von" tabindex="1">
    <span class="suggest"></span>'
    }
  { query: "#edit"
  func: (dom, req, res) ->
    if req.form
      console.log "EDIT"
      request req.form
      .pipe dom.createWriteStream()},
  { query: "#results"
  func: (dom, req, res) ->
    return unless req.u.id
    console.log "RESULTS " + req.u.id
    request API + req.u.route, headers: "accept": "stream/json"
    .pipe JSONStream.parse()
    .pipe es.map (ride, cb) ->
      if ride.route == req.u.route
        req.search = ride
      if ride.id == req.u.id
        req.ride = ride
      cb 0, render.row rowhtml, ride
    .pipe dom.createWriteStream()},
  { query: "#details"
  func: (dom, req, res) ->
    if req.ride
      console.log "DETAILS"
      r = req.u.route.split("/")
      dom.createWriteStream()
      .end render.details detailshtml,
        req.search, req.ride
}]

# STREAM HTML INTO STREAMING HTML
connect().use (req, res, next) ->
  if m = req.url.match /\/(inc\/.*\.css|inc\/js\/.*\.js|pix\/.*\.png|inc\/font\/.*)/
    req.url = m[1]
    proxy.web req, res, target: FORWARD
  else
    delete req.headers["if-modified-since"]
    delete req.headers["if-none-match"]
    req.u = url.match(req.url)
    switch req.u.div
      when "edit"
        req.form = SONNE + "/auth/ride/edit/" +
        req.u.id + "/" + req.url.split("/").pop()
      when "start"
        ip.resolve (s = req.connection.remoteAddress.split(":"))[s.length - 1], (place) ->
          console.log "IP #{req.connection.remoteAddress} is in #{place}"
          place = place.toLowerCase()
          req.place = place[0].toUpperCase() + place[1..place.length - 1]
          trompete(req, res, next)
        return
    trompete(req, res, next)


.use (req, res) ->
  req.url = "index.html"
  proxy.web req, res, target: FORWARD

.listen 4242

process.on "uncaughtException", (err) -> console.log "ERROR: " + err
