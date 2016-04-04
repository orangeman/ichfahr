# DOM HELP
append = (el, html, wo) -> el.insertAdjacentHTML wo || 'beforeend', html
remove = (id) -> e = $(id); e.parentNode.removeChild(e) if e
$ = (id) -> document.getElementById id

# animate nav after initial resize
$("wrapper").className = "sliding"

# MENU BAR
append document.body, navihtml, "afterbegin"
menus = document.getElementsByClassName("menu_head")
for menu in menus
  menu.onclick = (ul) -># first close all other menus that might be open
    m.classList.remove "open_submenu" for m in menus when m != ul.target
    ul.target.classList.toggle "open_submenu"
    if ul.target.classList.contains "open_submenu"
      window.dim window.url().div # DimderimDim
    else window.undim window.url().div
$("logo").onclick = (e) -> history.back()
$("full").onclick = (e) -> window.map?.full?() if window.url().div == "details"


# DATE PICKER
options =
  outputFormat: '%A, %d %B %Y', navigateYear: false
  months:
    short: ['Jan', 'Feb', 'März', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez']
    long: ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember']
  weekdays:
    short: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa']
    long: ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag']

append document.head, datepickcss
pick = require("./inc/js/vanilla.datepicker")
pick "#date", options, (d) -> rds.query dep: d.getTime()




# EDIT FORM
BASE = "http://pi.sonnenstreifen.de/auth/"
append document.head, restofcss
window.renderEdit = () ->
  if id = window.url().id
    window.renderDetails id
    $("details").style.display = "block"
  window.http.get BASE + "ride/empty_form", (e, r, html) ->
    append $("edit"), html
    initForm()

(initForm = () ->
  q = {} # changes
  $("input_ride_price")?.oninput = () ->
    rds.query price: q.price = this.value
  $("seats")?.onchange = (e) ->
    rds.query seats: q.seats = e.target.value
  $("mode")?.onchange = (e) ->
    console.log "MODE " + e.target.value
    rds.query mode: q.mode = e.target.value
  $("github")?.onclick = () ->
    window.open "https://ifoauth.herokuapp.com/auth/github?token=" +
      rds.token() + "&ride=" + window.q.id, "Auth", "height=400,width=300"
  $("description")?.oninput = () ->
    rds.query details: q.details = this.value

  $("btn_save")?.onclick = () ->
    console.log "click"
    q.guid = window.q.id
    q.origin = window.from().split(",")[0]
    q.destination = window.to().split(",")[0]
    q.mobile = $("mobile").value
    q.email = $("email").value
    window.http.post BASE + "ride/create", (e, r, body) ->
      console.log "und alle so yeah"
      console.log body
      console.log window.q.id
    .write q
)()


# SEARCH RIDES
window.query = () ->
  route = "/#{window.from().split(",")[0]}/#{window.to().split(",")[0]}"
  return unless route.match /\/[^\/]+\/[^\/]+/
  window.q.route = route
  console.log "POST #{window.q.route} #{window.q.id?}"
  rds.query route: route, status: "published", (done) ->
    console.log "Done POST" # find yourself
    if done.status != "deleted"
      window.q[k] = v for k, v of done
      update done



# STREAMING LIFE SOCKET
js = document.createElement "script"
js.src = "/inc/js/sockjs-0.3.4.min.js"
document.body.appendChild js
rds = null # RIDE DATA STORE
js.onload = () ->
  results = $ "results"
  sock = new SockJS(window.API + "/sockjs")
  rds = require("rds-client") sock, () ->
    window.query() # search on (re-)connect
  .on (ride) ->
    console.log "FOUND " + JSON.stringify ride
    return alert ride.fail if ride.fail
    results.innerHTML = ""
    for r in rds.sort "dep"
      append results, render.row rowhtml, r
    update ride unless ride.me

window.onbeforeunload = () -> rds?.close(); null

active = null
window.renderDetails = (id) ->
  ride = rds.get id
  return unless ride
  console.log "DETAILS " + id
  active?.classList.remove "active"
  (active = $(id))?.classList.add "active"
  $("details").innerHTML = render.details detailshtml, window.q, ride
  $("result_contact_options").innerHTML = render.contact ride.user
  window.map?.show? window.q, ride
  for p in document.getElementsByClassName "result_table_route_place"
    p.onclick = (e) -> window.map?.zoom @title || @textContent
  tooltips()

update = (ride) ->
  (active = $(active?.id))?.classList.add "active"
  if (u = window.url()).div == "details" || u.div == "edit"
    if u.id == ride.id || window.q.id == ride.id
      window.renderDetails u.id

render = require "./src/render"

tooltips = () ->
  for tt in document.getElementsByClassName("tooltip")
    tt.onclick = (e) ->
      for sib in @parentNode.children
        if sib.lastChild?.tagName == "P"
          sib.removeChild sib.lastChild
        sib.style.opacity = 0.5
      @style.opacity = 1
      append @, "<p class=\"tooltip_show\"><span>#{@title}</span></p>"
