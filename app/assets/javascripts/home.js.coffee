ready = ->
  console.log('Flash toastr ready fired')
  flashContainer = document.getElementById('flash-container')
  return unless flashContainer?

  flashContainer.querySelectorAll('.flash').forEach (el) ->
    if el.classList.contains('success')
      type = 'success'
    else if el.classList.contains('danger')
      type = 'danger'
    else if el.classList.contains('warning')
      type = 'warning'
    else
      type = 'primary'

    console.log("Calling toastr for type:", type, "message:", el.textContent.trim())

    if window.toastr? and typeof window.toastr[type] is 'function'
      window.toastr[type](el.textContent.trim())

  flashContainer.innerHTML = ''

$(document).on 'turbolinks:load turbo:load', ready
