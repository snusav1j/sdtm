// app/assets/javascripts/channels/consumer.js
//= require actioncable

(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();
}).call(this);
