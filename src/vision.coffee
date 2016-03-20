load = false

module.exports = (cb) ->
  return if load

  load = true
  css = document.createElement "link"
  css.rel = "stylesheet"
  css.href = "/inc/leaflet.css"
  document.head.appendChild css

  js = document.createElement "script"
  js.src = "/inc/js/leaflet.js"
  document.body.appendChild js
  js.onload = () ->

    m = document.createElement "div"
    m.id = "map"
    document.body.appendChild m
    map = L.map(m).setView [48.505, 9.09], 10
    #map.invalidateSize()

    L.tileLayer('http://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}.{ext}',
    	attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    	subdomains: 'abcd',
    	minZoom: 0,
    	maxZoom: 20,
    	ext: 'png'
    ).addTo map
    #L.control.zoom(position: "bottomright").addTo map

    cb map
