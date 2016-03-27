decode = require "./inc/js/decode"

document.head.insertAdjacentHTML 'beforeend', leafletcss
m = document.createElement "div"
m.id = "map"
document.body.appendChild m

map = L.map(m).setView [48.13743, 11.57549], 10

L.tileLayer('http://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.{ext}',
  attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  subdomains: 'abcd',
  minZoom: 0,
  maxZoom: 20,
  ext: 'png'
).addTo map
L.control.zoom(position: "bottomright").addTo map

Marker = L.Icon.extend
  options:
    shadowUrl: '/pix/marker_shadow.png'
    iconSize:     [38, 95]
    shadowSize:   [50, 64]
    iconAnchor:   [22, 94]
    shadowAnchor: [4, 62]

marker = (place, icon, cb) ->
  get place, (pl) ->
    L.marker(JSON.parse(pl), icon: new Marker iconUrl: icon).addTo(map);
    cb() if cb

path = (route, style, cb) ->
  get route, (path) ->
    area.push coords = decode path
    l = L.geoJson().addTo map
    l.options = style: style
    l.addData
      type: "LineString"
      coordinates: coords
    cb() if cb

area = []
panAndZoom = () ->
    bbx = [[99999999, 99999999], [0, 0]]
    for coords in area
      for ll in coords
        bbx[0][0] = ll[1] if ll[1] < bbx[0][0]
        bbx[0][1] = ll[0] if ll[0] < bbx[0][1]
        bbx[1][0] = ll[1] if ll[1] > bbx[1][0]
        bbx[1][1] = ll[0] if ll[0] > bbx[1][1]
    console.log "BBX " + JSON.stringify bbx
    map.fitBounds bbx, paddingTopLeft: [0, 50], animate: true, pan: animate: true, duration: 0.5

map.show = (passenger, driver) ->
  area = []
  [driver, passenger] = [passenger, driver] if driver.passenger
  map.eachLayer (l) -> map.removeLayer l unless l.getAttribution
  console.log "draw " + driver.route + " via " + passenger.route

  area = []
  pickup = "/#{driver.from}/#{passenger.from}" if driver.from != passenger.from
  dropoff = "/#{driver.to}/#{passenger.to}" if driver.to != passenger.to
  path driver.route, color: "#004565", weight: 9, opacity: 1
  path pickup, color: "#004565", weight: 7, dashArray:"1, 10", opacity: 1 if pickup
  path dropoff, color: "#004565", weight: 7, dashArray:"1, 10", opacity: 1 if dropoff
  path passenger.route, color: "#004565", weight: 7, dashArray:"1, 10", opacity: 1, () ->
    console.log "driver drawn"
    marker driver.from, "/pix/marker_blue.png"
    marker driver.to, "/pix/marker_light_blue.png"
    marker passenger.from, "/pix/marker_yellow.png"
    marker passenger.to, "/pix/marker_yellow.png", () ->
      console.log "icons drawn"
      path passenger.route, color: "#ffcc00", weight: 3, opacity: 1, () ->
        console.log "passenger drawn"
        map.adjust()

map.zoom = (p) ->
  console.log "ZOOM " + p
  get p.trim(), (pp) ->
    if pp.match /^\[\d+/ # isJson ;)
      map.setView JSON.parse(pp), 10, pan: animate: true
    else
      (area = []).push coords = decode pp
      panAndZoom()

map.adjust = () ->
  map.invalidateSize()
  panAndZoom()

  document.getElementById("full").onclick = () ->
    (m.requestFullscreen || m.mozRequestFullScreen || m.webkitRequestFullscreen || m.msRequestFullscreen)?.call? m
    document.addEventListener "fullscreenchange", (e) -> map.adjust()
    document.addEventListener "mozfullscreenchange", (e) -> map.adjust()
    document.addEventListener "webkitfullscreenchange", (e) -> map.adjust()
    document.addEventListener "msfullscreenchange", (e) -> map.adjust()

window.map = map



Cache = {}
get = (p, cb) ->
  if Cache[p]
    cb Cache[p]
  else
    what = if p.split("/").length > 1 then "/path" else "/place/"
    window.http.get window.API + what + p, (e, r, b) ->
      #console.log "P " + r.statusCode + " :: " + b
      cb Cache[p] = b if b
