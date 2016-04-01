decode = require "./inc/js/decode"

document.head.insertAdjacentHTML 'beforeend', leafletcss

m = document.createElement "div"
m.id = "map_wrapper"
document.body.appendChild m

l = document.createElement "div"
l.id = "map"
m.appendChild l

det = document.createElement "div"
det.id = "detour"
m.appendChild det

map = L.map(l).setView [48.13743, 11.57549], 10

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


pop = {}
marker = (place, icon, cb) ->
  get place, (pl) ->
    pop[place] =
      L.marker(JSON.parse(pl).latlon,
        icon: new Marker iconUrl: icon)
      .bindPopup popup(JSON.parse(pl)), offset: [-4, -19]
      .addTo(map)
    cb() if cb

popup = (p) ->
  "<h2>#{p.name}</h2>" +
  "<h3>#{p.adm1} / #{p.adm2} / #{p.adm3} / #{p.adm4}</h3>" +
  "#{p.timezone}</br></br>" +
  "Alternative Names:</br><ul>" +
  ("<li style=\"list-style: inside;\"><b>#{n}</b> (#{l})</li>" for n,l of p.alts).join("") +
  "</ul></br>Ambiguities:</br><ul>" +
  ("<li style=\"list-style: inside;\"><b>#{a.name}</b> </li>" for a in p.ambig?).join("") +
  "</ul>"

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
  det.innerHTML = "<h4>Umweg: <span>" + (driver.det || passenger.det) + "km</span></h4><div>über " +
    passenger.route + "</div>"


  area = []
  pickup = "/#{driver.from}/#{passenger.from}" if driver.from != passenger.from
  dropoff = "/#{driver.to}/#{passenger.to}" if driver.to != passenger.to
  path driver.route, color: "#004565", weight: 5, opacity: 1
  path pickup, color: "#208ddf", weight: 5, lineCap: 'butt', dashArray:"10, 10", opacity: 1 if pickup
  path dropoff, color: "#208ddf", weight: 5, lineCap: 'butt', dashArray:"10, 10", opacity: 1 if dropoff
  path passenger.route, color: "#208ddf", weight: 5, lineCap: 'butt', dashArray:"10, 10", opacity: 1, () ->
    console.log "driver drawn"
    marker driver.from, "/pix/marker_blue.png"
    marker driver.to, "/pix/marker_light_blue.png"
    marker passenger.from, "/pix/marker_yellow.png"
    marker passenger.to, "/pix/marker_yellow.png", () ->
      console.log "icons drawn"
      path passenger.route, color: "#ffcc00", weight: 5, lineCap: 'butt', dashArray:"0, 10, 10, 0",opacity: 1, () ->
        console.log "passenger drawn"
        map.adjust()

map.zoom = (p) ->
  console.log "ZOOM " + p
  get p.trim(), (pp) ->
    try
      x = JSON.parse(pp)
      map.setView x.latlon, 10, pan: animate: true
      pop[p.trim()].openPopup()
    catch error
      (area = []).push coords = decode pp
      panAndZoom()

map.adjust = () ->
  map.invalidateSize()
  panAndZoom()

map.full = () ->
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
