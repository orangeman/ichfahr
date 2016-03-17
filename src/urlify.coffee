
BASE = (window?.location?.origin || "http://ichfahr.de") + "/"

module.exports = (q) ->

  window.q = q = status: "published" unless q

  fun = (page, id) ->

    switch page
      when "suche"
        BASE
      when "mitfahrgelegenheit"
        BASE + page + q.route
      when "details"
        BASE + "mitfahrgelegenheit" + q.route + "/" + id
      when "edit"
        BASE + "mitfahrgelegenheit" + q.route + "/" + q.id + "/edit"


  fun.match = (url) ->

    if m = url.match /mitfahrgelegenheit\/.+\/.+\/(.+)/
      "details"
    else if m = url.match /mitfahrgelegenheit(\/.+\/.+)/
      "mitfahrgelegenheit"
    else
      "suche"

  fun
