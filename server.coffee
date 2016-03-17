#ecstatic = require("ecstatic")(".", cache: "no-cache")
request = require "request"
fs = require "fs"

require("http").createServer (req, res) ->
  if m = req.url.match /\/(inc\/.*\.css|inc\/js\/.*\.js|pix\/.*\.png|inc\/font\/.*)/
    console.log "FORWARD TO SONNE " + m[1]
    req.pipe(request("http://pi.sonnenstreifen.de/ichfahr/" + m[1])).pipe res
    #fs.createReadStream(m[1]).pipe res unless req.url.match /logo/
  else
    console.log "DELIVER single index.html page   for " + req.url
    request.get("http://pi.sonnenstreifen.de/ichfahr/index.html").pipe res
    #fs.createReadStream("index.html").pipe res
.listen 4242
