#ecstatic = require("ecstatic")(".", cache: "no-cache")
url = require("./src/urlify")()
http = require "http-proxy"
request = require "request"
connect = require "connect"
tralala = require "harmon"
fs = require "fs"

SONNE = "http://pi.sonnenstreifen.de/"
proxy = http.createProxyServer()
FORWARD = SONNE + "ichfahr/"

# LOCAL TEST SERVER
if process.argv[2] == "local"
  FORWARD = "http://localhost:5555/"
  require("http").createServer(require("ecstatic")("./")).listen 5555



# MIX AND MERGE STREAMS
Trompete = tralala [], [
  query: "#edit"
  func: (dom, req, res) ->
    request(req.edit_form).pipe dom.createWriteStream()
], true

# STREAM HTML INTO STREAMING HTML
connect().use (req, res, next) ->
  switch (u = url.match(req.url)).div
    when "edit"
      token = req.url.split("/").pop()
      req.edit_form = SONNE + "auth/ride/edit/#{u.id}/#{token}"
      Trompete(req, res, next)
    else next()

# FORWARD REQUESTS
.use (req, res) ->
  if m = req.url.match /\/(inc\/.*\.css|inc\/js\/.*\.js|pix\/.*\.png|inc\/font\/.*)/
    req.url = m[1]
  else
    req.url = "index.html"
  proxy.web req, res, target: FORWARD

.listen 4242
