mustache = require "mustache"
day = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa']
month = ['Jan', 'Feb', 'März', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez']
normalize = (n) -> if n > 9 then n else "0" + n
time = (d) -> normalize(d.getHours()) + ":" + normalize(d.getMinutes())
mm = (duration) -> "#{Math.floor(duration/60)}h #{duration % 60}min"
tt = (timestamp) -> time new Date(timestamp)

avatar = "style=\"background-image: url('{{ user.avatar }}');\""

module.exports =

  row: (html, ride) -> # search results
    g = if ride.pickup then "~ " else ""
    d = new Date(ride.dep + ride.pickup_time)
    ride.myride = if ride.me then "myride" else ""
    ride.departure = "#{day[d.getDay()]} #{g}#{time d}"
    ride.date = "#{d.getDate()} #{month[d.getMonth()]}"
    ride.title = "Gesuch: #{ride.from} > #{ride.to}, #{ride.departure}"
    ride.avatar = mustache.render avatar, ride if ride.user?.avatar
    mustache.render html, ride # row.html


  details: (html, q, ride) ->
    g = if ride.pickup then "~" else " "
    d = new Date(ride.dep + ride.pickup_time)
    ride.date = "#{d.getDate()} #{month[d.getMonth()]} #{d.getFullYear()}"
    ride.time_label = g + time d
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
  if pickup = p.pickup || d.pickup
    duration = p.pickup_time || d.pickup_time
    way.row duration, pickup, p.from, "via"
    if dropoff = p.dropoff || d.dropoff # pickup and dropoff
      way.row p.dist_time, p.dist, p.to, "via"
      duration = p.dropoff_time || d.dropoff_time
      way.row duration, dropoff, d.to, "to"
    else # only pickup
      way.row p.dist_time, p.dist, p.to, "to"
  else if dropoff = p.dropoff || d.dropoff # only dropoff
    way.row p.dist_time, p.dist, p.to, "via"
    duration = p.dropoff_time || d.dropoff_time
    way.row duration, dropoff, d.to, "to"
  else # no via at all
    way.row d.dist_time, d.dist, d.to, "to"
  way.render()

row = """
<tr class="result_table_route_dist_tr">
    <td class="result_table_route_place" title="{{ route }}">{{ dist }}</td>
    <td class="result_table_route_distance"></td>
    <td class="result_table_route_duration">{{ dur }}</td>
</tr>
<tr class="result_table_route_place_tr result_table_route_{{ icon }}">
    <td class="result_table_route_place">{{#bold}} {{ place }} {{/bold }}</td>
    <td class="result_table_route_total">{{ total }}</td>
    <td class="result_table_route_time">{{ guess }}{{ time }}</td>
</tr>
"""

table = (from, dep, bold) ->
  i = dep
  total = 0
  rows = [dur: "", dist: "", place: from, bold: bold(from), time: tt(dep), total: "0km", icon: "from"]
  row: (duration, dist, place, icon) ->
    guess = if icon == "from" then "" else "~ "
    rows.push
      dur: mm(duration), dist: dist + "km", icon: icon
      route: "/#{rows[rows.length - 1]?.place}/#{place}"
      time: guess + tt(i += duration * 60000)
      place: place, bold: bold(place)
      total: (total += dist) + "km"
  render: () ->
    html = ""
    html += mustache.render row, r for r in rows
    html
