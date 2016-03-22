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
  { query: "#edit"
  func: (dom, req, res) ->
    if req.form
      console.log "EDIT"
      request req.form
      .pipe dom.createWriteStream()},
  { query: "#results"
  func: (dom, req, res) ->
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
        return next()
    trompete(req, res, next)

.use (req, res) ->
  req.url = "index.html"
  proxy.web req, res, target: FORWARD

.listen 4242

process.on "uncaughtException", (err) -> console.log "ERROR: " + err
