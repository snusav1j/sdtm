window.toastr =
  _show: (status, msg) ->

    icons =
      success: '<i class="fa fa-check"></i>'
      danger:  '<i class="fa fa-remove"></i>'
      warning: '<i class="fa fa-warning"></i>'
      primary: '<i class="fa fa-info"></i>'

    # Удаляем старые уведомления
    document.querySelectorAll('.custom-toastr-container').forEach (el) ->
      el.remove()

    toastrContainer = document.createElement('div')
    toastrContainer.className = 'custom-toastr-container'

    toastrBlock = document.createElement('div')
    toastrBlock.className = "custom-toastr-block custom-toastr-#{status}"

    toastrIconBlock = document.createElement('div')
    toastrIconBlock.className = 'custom-toastr-icon'

    if icons[status]?
      toastrIconBlock.innerHTML = icons[status]
      toastrBlock.appendChild(toastrIconBlock)

    toastrBlock.insertAdjacentHTML('beforeend', msg)
    toastrContainer.appendChild(toastrBlock)

    document.body.prepend(toastrContainer)

    # Функция показа — объявлена выше вызовов
    showAnimation = ->
      setTimeout (-> toastrContainer.classList.add('show-toastr-container')), 50
      setTimeout (-> toastrContainer.classList.remove('show-toastr-container')), 2600
      setTimeout (-> toastrContainer.remove()), 3100

    showAnimation()

    toastrContainer.addEventListener 'click', ->
      toastrContainer.classList.remove('show-toastr-container')
      setTimeout (-> toastrContainer.remove()), 300

  success: (msg) -> window.toastr._show('success', msg)
  danger:  (msg) -> window.toastr._show('danger', msg)
  warning: (msg) -> window.toastr._show('warning', msg)
  primary: (msg) -> window.toastr._show('primary', msg)
