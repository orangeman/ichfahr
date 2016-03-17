
module.exports =

  get: (url, cb) ->
    console.log url
    request("GET", url, cb).send()

  post: (url, cb) ->
    p = request("POST", url, cb)
    write: (data) ->
      p.setRequestHeader "Content-Type", "application/json"
      p.setRequestHeader "Content-length", data.length
      p.send data



request = (method, url, cb) ->
  xhr = new XMLHttpRequest?() || new ActiveXObject('Microsoft.XMLHTTP')
  xhr.open method, url
  xhr.onreadystatechange = () ->
    cb xhr.readyState > 3, statusCode: xhr.status, xhr.responseText
  xhr
