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



# DATE PICK
append document.head, datepickcss
pick = require("./inc/js/vanilla.datepicker")
date = (d) -> rds.query dep: Date.parse d
pick "#date", {outputFormat:'%A, %d %B %Y'}, date
$("date").oninput = (e) -> date this.value



# EDIT FORM
BASE = "http://pi.sonnenstreifen.de/auth/"
append document.head, restofcss
window.http.get BASE + "ride/empty_form", (e, r, html) ->
  q = {} # changes
  append $("edit"), html
  $("input_ride_price").oninput = () ->
    rds.query price: q.price = this.value
  $("seats").onchange = (e) ->
    rds.query seats: q.seats = e.target.value
  $("mode").onchange = (e) ->
    console.log "MODE " + e.target.value
    rds.query mode: q.mode = e.target.value
  $("github").onclick = () ->
    window.open "https://ifoauth.herokuapp.com/auth/github?token=" +
      rds.token() + "&ride=" + q.id, "Auth", "height=400,width=300"
  $("description").oninput = () ->
    rds.query details: q.details = this.value

  $("btn_save").onclick = () ->
    console.log "click"
    window.http.post BASE + "ride/create", (e, r, body) ->
      console.log "und alle so yeah"
      q.id = window.q.id
    .write q



# SEARCH RIDES
window.query = () ->
  route = "/#{window.from()}/#{window.to()}"
  return unless route.match /\/[^\/]+\/[^\/]+/
  if route == q.route # no search same
    return # same query again
  else # new search!
    window.q.route = route
  console.log "POST #{window.q.route} #{window.q.id?}"
  rds.query route: route, status: "published", (done) ->
    console.log "Done POST" # find yourself
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
    update ride

window.renderDetails = (id) ->
  ride = rds.get id
  console.log "DETAILS " + id #+ " :: " + JSON.stringify ride
  $("details").innerHTML = render.details detailshtml, q, ride
  $("result_contact_options").innerHTML = render.contact ride.user
  window.showMap? q, ride

update = (ride) ->
  if (u = window.url()).div == "details"
    if u.id == ride.id || window.q.id == ride.id
      window.renderDetails u.id

render = require "./src/render"
