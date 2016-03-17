
append = (el, html, wo) -> el.insertAdjacentHTML wo || 'beforeend', html
remove = (id) -> (e = $(id)).parentNode.removeChild(e) if e
$ = (id) -> document.getElementById id

# INCLUDE REST OF STYLE AND HTML
append document.head, restofcss
append $("edit"), inserthtml

window.renderDetails = (id) ->
  console.log "DETAILS " + id
  append $("details"), detailshtml
  $("result_contact_options").innerHTML = contactshtml


# INITIALIZE MENU BAR
append document.body, navihtml, "afterbegin"
menus = document.getElementsByClassName("menu_head")
for menu in menus
  menu.onclick = (ul) ->
    m.classList.remove "open_submenu" for m in menus when m != ul.target
    ul.target.classList.toggle "open_submenu"
    if ul.target.classList.contains "open_submenu"
      window.dim window.location.pathname.split("/").pop()
    else
      window.undim window.location.pathname.split("/").pop()



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
  console.log "POST #{q.route} #{q.id}"
  rds.query q, (done) ->
    results.innerHTML = ""
    console.log "Done POST" # find yourself
    q.id = done.id


js = document.createElement "script"
js.src = "/inc/js/sockjs-0.3.4.min.js"
document.body.appendChild js

rds = null # RIDE DATA STORE
js.onload = () ->
  results = $ "results"
  # CONNECT TO STREAMING LIFE COMMUNICATION SOCKET
  rds = require("../rds-client") window.API, () ->
    window.query() # search on re-connect
  .on (ride) ->
    console.log "FOUND " + JSON.stringify ride
    return alert ride.fail if ride.fail
    remove ride.id
    if ride.status != "deleted"
      append results, render ride
      # dirty tmp hack  for direct deep link to details
      if window.location.pathname.split("/").length == 5
        window.renderDetails window.location.pathname.split("/")[4]

# ONE LIST ROW
render = (ride) ->
  [a, weekday, month, day, time] = new Date().toString().match /(\w*)\s(\w*)\s(\d+)\s\d+\s(\d+:\d+):/
  ride.departure = "#{weekday} #{time}"
  ride.date = "#{day} #{month}"
  ride.title = "Gesuch: #{ride.from} > #{ride.to}, #{ride.departure}"
  mustache.render rowhtml, ride

mustache = require "mustache"
