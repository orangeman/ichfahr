BASE = window.location.origin + "/m/"

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

slideTo = null
last = null

url = (page) ->
  unless last == page
    history.pushState {}, last = page, BASE + page

goTo = (page) ->
  slideOut "result_contact"
  slideOut "btn_insert"
  undim "details"
  slideTo page
  show page



#####   CLICK NAVIGATION   ######

$("btn_search").onclick = () ->
  goTo "mitfahrgelegenheit"
  url "mitfahrgelegenheit"
  window.query()

$("btn_offer").onclick = () ->
  if last != "insert"
    show "btn_save"
    goTo "insert"
    url "insert"
  else history.back()

$("results").onclick = (e) ->
  id = findParent "LI", e.target
  console.log "DETAILS id" + id
  window.renderDetails id # m.js
  goTo "details#" + id
  url "details#" + id

$("btn_contact").onclick = () ->
  if last != "contact"
    url "contact"
    dim "details"
    $("result_contact_options").className = "result_contact_open"
  else history.back()

window.onpopstate = (e) -> # BACK
  if last == "insert"
    hide "insert"
    hide "btn_save"
  else if last == "contact"
    undim "details"
    $("result_contact_options").className = "result_contact_closed"
  goTo last = window.location.pathname.split("/").pop()



########   SCREEN DEPENDENT LOGIC   #########

(window.onresize = (event) ->

  width = Math.max(document.documentElement.clientWidth, window.innerWidth || 0)

  if width <= 580 # MOBILE small screen

    slideTo = (page) ->
      switch page
        when "suche"
          setMargin 0
        when "insert"
          true
        when "mitfahrgelegenheit"
          setMargin -1 * width
          slideIn "btn_insert"
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
        when "insert"
          hide "mitfahrgelegenheit"
          hide "details"
          show "insert"
        when "mitfahrgelegenheit"
          hide "insert"
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
        when "insert"
          show "btn_save"
        when "mitfahrgelegenheit"
          setMargin 0
          slideOut "result_contact"
        else #details
          setMargin -0.5 * width
          slideIn "result_contact"
          slideIn "btn_insert"


  else # DESKTOP large screen

    slideTo = (page) ->
      setMargin 0
      switch page
        when "suche"
          hide "details"
        when "insert"
          true
        when "mitfahrgelegenheit"
          hide "details"
          slideOut "result_contact"
        else #details
          setMargin -0.33 * width
          slideIn "result_contact"
          show "details"


  last = window.location.pathname.split("/").pop()
  goTo last # direct link or page refresh
)() # initial function call


auto = require "auto-suggest"
window.from = auto $("from"), "Berlin"
window.to = auto $("to"), "Freiburg"


js = document.createElement "script"
js.src = "/m/m.js";
document.body.appendChild js
#document.body.insertAdjacentHTML 'beforeend', '<script src="/m/main.js"></script>'