
module.exports =

  get: (url, cb) ->
    request("GET", url, cb).send()

  post: (url, cb) ->
    p = request("POST", url, cb)
    write: (data) ->
      body = ""
      (body += (k + "=" + encodeURI(v) + "&") for k, v of data).slice 0, -1
      console.log body
      p.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
      p.setRequestHeader "Content-length", body.length
      p.send body



request = (method, url, cb) ->
  xhr = null
  if XMLHttpRequest
    xhr = new XMLHttpRequest()
  else
    xhr = new ActiveXObject('Microsoft.XMLHTTP')
  xhr.open method, url
  xhr.onreadystatechange = () ->
    if xhr.readyState > 3
      cb null, statusCode: xhr.status, xhr.responseText
  xhr
