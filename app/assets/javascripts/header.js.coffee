document.addEventListener 'DOMContentLoaded', ->
  header = document.querySelector('.app-header')
  body = document.querySelector('.app-body')
  sidebar = document.querySelector('#sidebar')

  headerHeight = 0

  updateHeaderHeight = ->
    headerHeight = header.getBoundingClientRect().height

  updateHeaderHeight()
  window.addEventListener 'resize', updateHeaderHeight

  window.addEventListener 'scroll', ->
    if window.scrollY > 0
      header.style.position = 'fixed'
      header.style.top = '0'
      header.style.left = '0'
      header.style.right = '0'
      header.style.background = 'white'
      body.style.paddingTop = "#{headerHeight}px"
      sidebar.style.marginTop = "#{headerHeight + 15}px"
    else
      header.style.position = ''
      header.style.top = ''
      header.style.left = ''
      header.style.right = ''
      header.style.background = ''
      body.style.paddingTop = ''
      sidebar.style.marginTop = ''
