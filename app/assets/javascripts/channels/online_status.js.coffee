App.cable.subscriptions.create "OnlineStatusChannel",
  connected: ->
    console.log "User online"
  disconnected: ->
    console.log "User offline"