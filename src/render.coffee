mustache = require "mustache"

parse = (t) -> new Date(t).toString().match /(\w*)\s(\w*)\s(\d+)\s(\d+)\s(\d+:\d+):/

module.exports =

  row: (html, ride) -> # search results
    [a, weekday, month, day, year, time] = parse ride.time
    ride.departure = "#{weekday} #{time}"
    ride.date = "#{day} #{month}"
    ride.title = "Gesuch: #{ride.from} > #{ride.to}, #{ride.departure}"
    mustache.render html, ride # row.html


  details: (html, ride) ->
    console.log "details " +  JSON.stringify ride
    [a, weekday, month, day, year, time] = parse ride.time
    ride.date = "#{day} #{month} #{year}"
    ride.time_label = time
    ride.route_html = route ride
    mustache.render html, ride


  contact: (user) ->
    html = ""
    if user?.email
      html += mustache.render t, label: "eMail senden", k: "mailto", v: user.email
    if user?.mobile
      html += mustache.render t, label: "anrufen", k: "tel", v: user.mobile
      html += mustache.render t, label: "sms schicken", k: "sms", v: user.mobile
t = '<li><a href="{{p}}:{{v}}" class="call2action result_contact_{{p}}">{{label}}</a></li>'


route = (ride) ->
  html = ""
  d = ride
  p = window.q
  return unless d.id && p.id
  if ride.passenger
    d = window.q
    p = ride
  tt = (timestamp) -> parse(timestamp)[5]
  bold = (place) -> () -> (text, render) ->
    if place == window.q.from || place == window.q.to
      "<b>" + render(text) + "</b>"
    else render text
  way = [place: d.from, dist: 0, time: tt(d.dep), bold: bold(d.from)]
  if p.from != d.from
    way.push place: p.from, dist: d.pickup, time: tt(d.dep + d.pickup_time * 60000), bold: bold(p.from)
  if p.to != d.to
    way.push place: p.to, dist: p.dist, time: tt(d.dep + (d.pickup_time + p.dist_time) * 60000), bold: bold(p.to)
  way.push place: d.to, dist: d.dist, time: tt(d.dep + d.dist_time * 60000), bold: bold(d.to)
  html += mustache.render row, point for point in way
  html

row = """
<tr>
    <td class="result_table_route_1st">{{#bold}} {{ place }} {{/bold }}</td>
    <td class="result_table_route_2nd">{{ time }}</td>
    <td class="result_table_route_3rd">{{ dist }}km</td>
</tr>
"""
