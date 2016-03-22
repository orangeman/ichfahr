mustache = require "mustache"

parse = (t) -> new Date(t).toString().match /(\w*)\s(\w*)\s(\d+)\s(\d+)\s(\d+:\d+):/

module.exports =

  row: (html, ride) -> # search results
    [a, weekday, month, day, year, time] = parse ride.dep
    ride.departure = "#{weekday} #{time}"
    ride.date = "#{day} #{month}"
    ride.title = "Gesuch: #{ride.from} > #{ride.to}, #{ride.departure}"
    mustache.render html, ride # row.html


  details: (html, q, ride) ->
    [a, weekday, month, day, year, time] = parse ride.dep
    ride.date = "#{day} #{month} #{year}"
    ride.time_label = time
    ride.route_html = route q, ride
    mustache.render html, ride


  contact: (user) ->
    html = ""
    if user?.email
      html += mustache.render t, label: "eMail senden", k: "mailto", v: user.email
    if user?.mobile
      html += mustache.render t, label: "anrufen", k: "tel", v: user.mobile
      html += mustache.render t, label: "sms schicken", k: "sms", v: user.mobile
    html = "Faben FAIL & PHP Server FAIL :P" if html == ""
    html
t = '<li><a href="{{k}}:{{v}}" class="call2action result_contact_{{p}}">{{label}}</a></li>'


route = (q, ride) -> # passenger, driver
  [d, p] = [ride, q]
  return unless d?.id && p?.id
  [d, p] = [p, d] if d.passenger
  bold = (place) -> () -> (text, render) ->
    if place == q.from || place == q.to
      "<b>" + render(text) + "</b>"
    else render text
  way = table d.from, d.dep, bold
  if pickup = p.pickup  || d.pickup
    duration = p.pickup_time || d.pickup_time
    way.row duration, pickup, p.from
    way.row p.dist_time, p.dist, p.to
    if dropoff = p.dropoff || d.dropoff # pickup and dropoff
      duration = p.dropoff_time || d.dropoff_time
      way.row duration, dropoff, d.to
  else if dropoff = p.dropoff || d.dropoff # only dropoff
    way.row p.dist_time, p.dist, p.to
    duration = p.dropoff_time || d.dropoff_time
    way.row duration, dropoff, d.to
  else # no via at all
    way.row d.dist_time, d.dist, d.to
  way.render()

row = """
<tr>
    <td class="result_table_route_duration">{{ dur }}</td>
    <td class="result_table_route_distance">{{ dist }}</td>
    <td class="result_table_route_place">{{#bold}} {{ place }} {{/bold }}</td>
    <td class="result_table_route_time">{{ time }}</td>
    <td class="result_table_route_total">{{ total }}</td>
</tr>
"""

table = (from, dep, bold) ->
  total = 0
  time = dep
  rows = [dur: "", dist: "", place: from, bold: bold(from), time: tt(dep), total: "0km", ]
  row: (duration, dist, place) ->
    rows.push
      dur: mm(duration), dist: dist + "km"
      place: place, bold: bold(place)
      time: tt(time += duration * 60000)
      total: (total += dist) + "km"
  render: () ->
    html = ""
    html += mustache.render row, r for r in rows
    html

tt = (timestamp) -> parse(timestamp)[5]
mm = (duration) -> "#{Math.floor(duration/60)}h #{duration % 60}min"
