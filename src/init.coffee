
########   DOM/CSS HELPERS   ########

$ = (id) -> document.getElementById id
hide = (p) -> $(p)?.style.display = "none"
show = (p) -> $(p)?.style.display = "block"
slideIn = (id) -> $(id)?.style.bottom = "0px"
slideOut = (id) -> $(id)?.style.bottom = "-80px"
setMargin = (m) -> $("wrapper").style['left'] = "#{m}px"

window.undim = undim = (id) ->
  $(id)?.style.opacity = "1"
  $(id)?.onclick = null
window.dim = dim = (id) ->
  $(id)?.style.opacity = ".2"
  $(id)?.onclick = () -> undim id

findParent = (tag, el) ->
  (true while (el = el.parentNode).tagName != tag)
  el.id



########   NAV HELPERS   #########

last = null
slideTo = null
window.q = {} # current query
urlify = require("./src/urlify")()
window.url = () -> urlify.match window.location.href


url = (div, id) ->
  if div == last
    history.replaceState {}, div, urlify div, id
  else
    history.pushState {}, last = div, urlify div, id

goTo = (div) ->
  slideOut "result_contact"
  slideOut "btn_edit"
  undim "details"
  slideTo div
  show div



#####   CLICK NAVIGATION   ######

$("btn_search").onclick = () ->
  window.query()
  url "mitfahrgelegenheit"
  goTo "mitfahrgelegenheit"

$("btn_offer").onclick = () ->
  if last != "edit"
    show "btn_save"
    goTo "edit"
    url "edit"
  else history.back()

$("results").onclick = (e) ->
  id = findParent "LI", e.target
  window.renderDetails id # m.js
  url "details", id
  goTo "details"

$("btn_contact").onclick = () ->
  if last != "contact"
    url "contact"
    dim "details"
    $("result_contact_options").className = "result_contact_open"
  else history.back()

window.onpopstate = (e) -> # BACK
  if last == "edit"
    hide "edit"
    hide "btn_save"
  else if last == "contact"
    undim "details"
    $("result_contact_options").className = "result_contact_closed"
  goTo last = window.url().div



########   SCREEN DEPENDENT LOGIC   #########

(window.onresize = (event) ->

  width = Math.max(document.documentElement.clientWidth, window.innerWidth || 0)

  if width <= 580 # MOBILE small screen

    slideTo = (div) ->
      switch div
        when "start"
          setMargin 0
        when "edit"
          true
        when "mitfahrgelegenheit"
          setMargin -1 * width * 0.97
          slideIn "btn_edit"
        else #details
          setMargin -2 * width * 0.97
          slideIn "result_contact"
          hide "btn_save"


  else if width < 680 # FABLET small landscape
    setMargin 0

    slideTo = (div) ->
      switch div
        when "start"
          true
        when "edit"
          hide "mitfahrgelegenheit"
          hide "details"
          show "edit"
        when "mitfahrgelegenheit"
          hide "edit"
          hide "details"
          slideOut "result_contact"
          show "mitfahrgelegenheit"
        else #details
          hide "edit"
          hide "mitfahrgelegenheit"
          slideIn "result_contact"


  else if width < 900 # TABLET medium screen

    slideTo = (div) ->
      switch div
        when "start"
          setMargin 0
        when "edit"
          show "btn_save"
        when "mitfahrgelegenheit"
          setMargin 0
          slideOut "result_contact"
        else #details
          setMargin -0.5 * width
          show "mitfahrgelegenheit"
          slideIn "result_contact"
          slideIn "btn_edit"


  else # DESKTOP large screen
    map = "yay"

    slideTo = (div) ->
      setMargin 0
      switch div
        when "start"
          hide "map"
          hide "details"
        when "edit"
          hide "map"
          show "mitfahrgelegenheit"
        when "mitfahrgelegenheit"
          hide "map"
          hide "details"
          slideOut "result_contact"
        else #details
          setMargin -0.33 * width
          slideIn "result_contact"
          show "details"
          setTimeout (() ->
            show "map"
            console.log "INVALIDATE"
            map.reAdjust()
          ), 450

    require("./src/vision") (m) -> map = m

# direct deep link  or refresh
  goTo last = window.url().div
)()


window.API = "http://pi.sonnenstreifen.de:5000"
window.http = http = require "./src/request"
auto = require "auto-suggest"

complete = (text, render) ->
  http.get "#{window.API}?q=#{encodeURI(text)}", (err, res, names) ->
    render names.split ","

route = window.url().route?.match /\/(.*)\/(.*)/ # default values
window.from = auto $("from"), complete, route?[1], () -> $("btn_search").onclick()
window.to = auto $("to"), complete, route?[2], () -> $("btn_search").onclick()

# LOAD REST OF THE HTML / CSS / JS
js = document.createElement "script"
js.src = "/inc/js/m.js"
document.body.appendChild js
#document.body.insertAdjacentHTML 'beforeend', '<script src="/m/main.js"></script>'
