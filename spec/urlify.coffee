
spec = require "tape"

url = require("../src/urlify") q =
  route: "/Berlin/Munich"
  id: "abc37" # me



spec "MAKE URL from query params", (t) ->

  t.equal url("mitfahrgelegenheit"), "http://ichfahr.de/mitfahrgelegenheit/Berlin/Munich"

  t.equal url("details", "xy3"), "http://ichfahr.de/mitfahrgelegenheit/Berlin/Munich/xy3"

  t.equal url("edit"), "http://ichfahr.de/mitfahrgelegenheit/Berlin/Munich/abc37/edit"

  t.equal url("suche"), "http://ichfahr.de/"

  t.end()



spec "MATCH URL into query params", (t) ->

  t.equal url.match("http://ichfahr.de/mitfahrgelegenheit/Bar/Home"), "mitfahrgelegenheit"
  t.equal q.route, "/Bar/Home", "search params changed"

  t.equal url.match("http://ichfahr.de/mitfahrgelegenheit/Berlin/Munich/xy23"), "details"
  t.equal q.route, "/Bar/Home", "view details does not change search param"

  t.equal url.match("http://ichfahr.de/"), "suche"

  t.end()
