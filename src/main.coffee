# DOM HELPERS
append = (el, html, wo) -> el.insertAdjacentHTML wo || 'beforeend', html
remove = (id) -> e = $(id); e.parentNode.removeChild(e) if e
$ = (id) -> document.getElementById id


# INCLUDE EDIT FORM / AND STYLE
append document.head, restofcss
append $("edit"), inserthtml


# INITIALIZE MENU BAR
append document.body, navihtml, "afterbegin"
menus = document.getElementsByClassName("menu_head")
for menu in menus
  menu.onclick = (ul) -># first close all other menus that might be open
    m.classList.remove "open_submenu" for m in menus when m != ul.target
    ul.target.classList.toggle "open_submenu"
    if ul.target.classList.contains "open_submenu"
      window.dim window.url().div # DimderimDim
    else window.undim window.url().div



# SEARCH RIDES ..
q = window.q || {}
window.query = () ->
  route = "/#{window.from()}/#{window.to()}"
  return unless route.match /\/\w+\/\w+/
  if route == q.route # no search same
    console.log "return"
    return # same query again
  else # new search!
    q.route = route
  console.log "POST #{q.route} #{q.id?}"
  results.innerHTML = ""
  rds.query q, (done) ->
    console.log "Done POST" # find yourself
    window.q = done
    update done



# CONNECT TO STREAMING LIFE SOCKET
js = document.createElement "script"
js.src = "/inc/js/sockjs-0.3.4.min.js"
document.body.appendChild js
rds = null # RIDE DATA STORE
js.onload = () ->
  results = $ "results"
  rds = require("../rds-client") window.API, () ->
    window.query() # search on (re-)connect
  .on (ride) ->
    console.log "FOUND " + JSON.stringify ride
    return alert ride.fail if ride.fail
    remove ride.id
    if ride.status != "deleted"
      append results, render.row rowhtml, ride
      update ride

window.renderDetails = (id) ->
  console.log "DETAILS " + id
  ride = rds.get id
  $("details").innerHTML = render.details detailshtml, ride
  $("result_contact_options").innerHTML = render.contact ride.user

update = (ride) ->
  if (u = window.url()).div == "details"
    if u.id == ride.id || window.q.id == ride.id
      window.renderDetails u.id

render = require "./src/render"
