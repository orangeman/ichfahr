
module.exports =

  get: (url, cb) ->
    request("GET", url, cb).send()

  post: (url, cb) ->
    p = request("POST", url, cb)
    write: (data) ->
      body = ""
      body += ((k + "=" + encodeURI(v) + "&") for k, v of data).slice 0, -1
      p.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
      p.setRequestHeader "Content-length", body.length
      p.send body



request = (method, url, cb) ->
  xhr = new XMLHttpRequest?() || new ActiveXObject('Microsoft.XMLHTTP')
  xhr.open method, url
  xhr.onreadystatechange = () ->
    cb xhr.readyState > 3, statusCode: xhr.status, xhr.responseText
  xhr
