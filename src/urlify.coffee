
BASE = (window?.location?.origin || "http://ichfahr.de") + "/"

module.exports = (q) ->

  q = window?.q || status: "published" unless q

  fun = (page, id) ->

    switch page
      when "start"
        BASE
      when "mitfahrgelegenheit"
        BASE + page + q.route
      when "details"
        BASE + "mitfahrgelegenheit" + q.route + "/" + id
      when "edit"
        BASE + "mitfahrgelegenheit" + q.route + "/" + q.id + "/edit"


  fun.match = (url) ->

    if m = url.match /mitfahrgelegenheit(\/[^\/]+\/[^\/]+)\/([^\/]+)\/edit/
      div: "edit", route: decodeURI(m[1]), id: m[2]
    else if m = url.match /mitfahrgelegenheit(\/[^\/]+\/[^\/]+)\/([^\/#]+)/
      div: "details", route: decodeURI(m[1]), id: m[2]
    else if m = url.match /mitfahrgelegenheit(\/[^\/]+\/[^\/]+)/
      div: "mitfahrgelegenheit", route: decodeURI(m[1])
    else
      div: "start"

  fun
