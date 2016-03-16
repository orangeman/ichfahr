

build = require "build-util"

build (i) ->
  i.append "src/init.coffee"
  i.browserify "inc/js/i.js"#, mini: true

build (m) ->
  #FILES AS STRING VARS
  m.inline "inc/restof.css"
  m.inline "inc/html/details.html"
  m.append "src/main.coffee"
  m.browserify "inc/js/m.js"#, mini: true