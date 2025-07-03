initSidebar = ->

  sidebar = document.getElementById "sidebar"
  overlay = document.getElementById "sidebar-overlay"
  toggleBtn = document.getElementById "sidebar-toggle"
  header = document.querySelector('.app-header')

  return unless sidebar and overlay and toggleBtn

  toggleSidebar = ->
    sidebar.classList.toggle "active"
    overlay.classList.toggle "active"
    toggleBtn.style.display = if sidebar.classList.contains("active") then "none" else "block"

  document.removeEventListener "click", @clickHandler if @clickHandler?

  @clickHandler = (event) ->
    target = event.target

    if target.closest("#sidebar-toggle")
      event.preventDefault()
      event.stopPropagation()
      header.style.zIndex  = '1000'
      toggleSidebar()
      return

    if target.closest("#sidebar-overlay")
      event.preventDefault()
      sidebar.classList.remove "active"
      overlay.classList.remove "active"
      toggleBtn.style.display = "block"
      header.style.zIndex  = '1555'

      return

    if sidebar.classList.contains("active") and
       not sidebar.contains(target) and
       not target.closest("#sidebar-toggle") and
       not target.closest("#sidebar-overlay")
      sidebar.classList.remove "active"
      overlay.classList.remove "active"
      toggleBtn.style.display = "block"
      header.style.zIndex  = '1555'

  document.addEventListener "click", @clickHandler

document.addEventListener "DOMContentLoaded", initSidebar
document.addEventListener "turbo:load", initSidebar
document.addEventListener "turbolinks:load", initSidebar
