
spec = require "tape"

url = require("../src/urlify") q =
  route: "/Berlin/Munich"
  id: "abc37" # me



spec "MAKE URL from query params", (t) ->

  t.equal url("mitfahrgelegenheit"), "http://ichfahr.de/mitfahrgelegenheit/Berlin/Munich"

  t.equal url("details", "xy3"), "http://ichfahr.de/mitfahrgelegenheit/Berlin/Munich/xy3"

  t.equal url("edit"), "http://ichfahr.de/mitfahrgelegenheit/Berlin/Munich/abc37/edit"

  t.equal url("start"), "http://ichfahr.de/"

  t.end()



spec "MATCH URL into query params", (t) ->

  m = url.match("http://ichfahr.de/mitfahrgelegenheit/Bar/Home")
  t.equal m.div, "mitfahrgelegenheit"
  t.equal m.route, "/Bar/Home"

  m = url.match("http://ichfahr.de/mitfahrgelegenheit/K%C3%B6ln/Frankfurt%20am%20Main")
  t.equal m.div, "mitfahrgelegenheit"
  t.equal m.route, "/Köln/Frankfurt am Main", "umlauts and spaces"

  m = url.match("http://ichfahr.de/mitfahrgelegenheit/Berlin/Munich/xy23")
  t.equal m.route, "/Berlin/Munich"
  t.equal m.div, "details"
  t.equal m.id, "xy23"

  m = url.match("http://ichfahr.de/mitfahrgelegenheit/Berlin/Munich/xy23#")
  t.equal m.route, "/Berlin/Munich"
  t.equal m.div, "details"
  t.equal m.id, "xy23"

  m = url.match("http://ichfahr.de/mitfahrgelegenheit/Berlin/Munich/abc37/edit")
  t.equal m.route, "/Berlin/Munich"
  t.equal m.div, "edit"
  t.equal m.id, "abc37"

  m = url.match("http://ichfahr.de/mitfahrgelegenheit/Berlin/Munich/abc37/edit/adsfghjlk")
  t.equal m.route, "/Berlin/Munich"
  t.equal m.div, "edit"
  t.equal m.id, "abc37"

  m = url.match("http://ichfahr.de/")
  t.equal m.div, "start"

  m = url.match("http://ichfahr.de")
  t.equal m.div, "start"

  t.end()
