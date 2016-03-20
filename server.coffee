#ecstatic = require("ecstatic")(".", cache: "no-cache")
request = require "request"
url = require("./src/urlify")()
fs = require "fs"

require("http").createServer (req, res) ->

  if m = req.url.match /\/(inc\/.*\.css|inc\/js\/.*\.js|pix\/.*\.png|inc\/font\/.*)/
    console.log "FORWARD TO SONNE " + m[1]
    req.pipe(request("http://pi.sonnenstreifen.de/ichfahr/" + m[1])).pipe res
  else
    switch (u = url.match(req.url)).div
      when "start"
        request.get("http://pi.sonnenstreifen.de/ichfahr/index.html").pipe res
      when "mitfahrgelegenheit"
        request.get("http://pi.sonnenstreifen.de/ichfahr/index.html").pipe res
      when "details"
        request.get("http://pi.sonnenstreifen.de/ichfahr/index.html").pipe res
      when "edit"
        token = req.url.split("/").pop()
        req.pipe(request.get("http://pi.sonnenstreifen.de/auth/ride/edit/#{u.id}/#{token}")).pipe res
      else
        res.end()

.listen 4242
