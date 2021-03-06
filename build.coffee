

build = require "build-util"

build (i) ->
  i.append "src/init.coffee"
  i.browserify "inc/js/i.js"#, mini: true

build (m) ->
  #FILES AS STRING VARS
  m.inline "inc/restof.css"
  m.inline "inc/datepick.css"
  m.inline "inc/html/row.html"
  m.inline "inc/html/navi.html"
  m.inline "inc/html/details.html"
  m.append "src/main.coffee"
  m.browserify "inc/js/m.js"#, mini: true

build (map) ->
  map.inline "inc/leaflet.css"
  map.append "src/vision.coffee"
  map.browserify "inc/js/map.js",
    include: "inc/js/leaflet.js"
