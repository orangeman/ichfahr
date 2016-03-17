
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

urlify = require("./src/urlify")()
slideTo = null
last = null

url = (page, id) ->
  unless last == page
    history.pushState {}, last = page, urlify page, id

goTo = (page) ->
  slideOut "result_contact"
  slideOut "btn_edit"
  undim "details"
  slideTo page
  show page



#####   CLICK NAVIGATION   ######

$("btn_search").onclick = () ->
  goTo "mitfahrgelegenheit"
  url "mitfahrgelegenheit"
  window.query()

$("btn_offer").onclick = () ->
  if last != "edit"
    show "btn_save"
    goTo "edit"
    url "edit"
  else history.back()

$("results").onclick = (e) ->
  id = findParent "LI", e.target
  console.log "DETAILS id" + id
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
  goTo last = urlify.match window.location.href



########   SCREEN DEPENDENT LOGIC   #########

(window.onresize = (event) ->

  width = Math.max(document.documentElement.clientWidth, window.innerWidth || 0)

  if width <= 580 # MOBILE small screen

    slideTo = (page) ->
      switch page
        when "suche"
          setMargin 0
        when "edit"
          true
        when "mitfahrgelegenheit"
          setMargin -1 * width
          slideIn "btn_edit"
          window.query()
        else #details
          setMargin -2 * width
          slideIn "result_contact"



  else if width < 680 # FABLET small landscape
    setMargin 0

    slideTo = (page) ->
      switch page
        when "suche"
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
          hide "mitfahrgelegenheit"
          slideIn "result_contact"


  else if width < 900 # TABLET medium screen

    slideTo = (page) ->
      switch page
        when "suche"
          setMargin 0
        when "edit"
          show "btn_save"
        when "mitfahrgelegenheit"
          setMargin 0
          slideOut "result_contact"
        else #details
          setMargin -0.5 * width
          slideIn "result_contact"
          slideIn "btn_edit"


  else # DESKTOP large screen

    slideTo = (page) ->
      setMargin 0
      switch page
        when "suche"
          hide "details"
        when "edit"
          true
        when "mitfahrgelegenheit"
          hide "details"
          slideOut "result_contact"
        else #details
          setMargin -0.33 * width
          slideIn "result_contact"
          show "details"


# direct deep link / page refresh / window resize
  goTo last = urlify.match window.location.href
)() # initial function call


auto = require "auto-suggest"
window.API = "http://localhost:5000"
window.from = auto $("from"), window.API, "Berlin"
window.to = auto $("to"), window.API, "Freiburg"


js = document.createElement "script"
js.src = "inc/js/m.js"
document.body.appendChild js
#document.body.insertAdjacentHTML 'beforeend', '<script src="/m/main.js"></script>'
