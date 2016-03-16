
append = (el, html, wo) -> el.insertAdjacentHTML wo || 'beforeend', html
$ = (id) -> document.getElementById id

# INCLUDE REST OF STYLE AND HTML
append $("details"), detailshtml
append document.head, restofcss
append $("insert"), inserthtml
append document.body, navihtml, "afterbegin"

window.renderDetails = (id) ->
  $("result_contact_options").innerHTML = contactshtml


# INITIALIZE MENU BAR
menus = document.getElementsByClassName("menu_head")
for menu in menus
  menu.onclick = (ul) ->
    m.classList.remove "open_submenu" for m in menus when m != ul.target
    ul.target.classList.toggle "open_submenu"
    if ul.target.classList.contains "open_submenu"
      console.log "open " + window.location.pathname.split("/").pop()
      window.dim window.location.pathname.split("/").pop()
    else
      console.log "close " + window.location.pathname.split("/").pop()
      window.undim window.location.pathname.split("/").pop()
