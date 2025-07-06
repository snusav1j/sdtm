recipient_id = $('#messages').data('recipient-id')

if recipient_id
  App.messages = App.cable.subscriptions.create {
    channel: "MessagesChannel",
    recipient_id: recipient_id
  },
    connected: ->
      console.log "Подключен к чату с пользователем ##{recipient_id}"
      $.ajax
        url: '/messages/load_messages'
        data: { recipient_id: recipient_id }
        success: (data) ->
          $('#messages').html(data)
          $('#messages').scrollTop($('#messages')[0].scrollHeight)

    disconnected: ->
      console.log "Отключен от чата"

    received: (data) ->
      # console.log "Получено сообщение:", data

      if window.location.href.indexOf('messages') >= 0
        current_id = parseInt($('#messages').attr('data-current-user-id'))
        msg = $(data.message)
        # recipient_id = parseInt(msg.attr('data-recipient-id'))
        recipient_id = parseInt($('#messages').attr('data-recipient-id'))
        sender_id = $(data.message).filter('div.message').first().data('sender-id')

        if sender_id == current_id
          msg.addClass('own')
        else
          msg.removeClass('own')
        $('#messages').append msg
        $('#messages').scrollTop $('#messages')[0].scrollHeight
      else
        toastr.success('У вас новое сообщение')