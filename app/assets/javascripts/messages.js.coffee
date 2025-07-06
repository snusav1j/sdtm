$ ->

  $(document).on 'keyup', 'input#message_body', (e) ->
    message = $(this).val()
    send_btn = $('.send-msg-btn')

    if message != '' && message != undefined
      send_btn.fadeIn(150)
    else
      send_btn.fadeOut(150)