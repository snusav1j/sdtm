ready = ->
  $('#symbol-select').select2
    ajax:
      url: '/forecasts/coins_search'
      dataType: 'json'
      delay: 250
      data: (params) -> { q: params.term }
      processResults: (data) ->
        results = data.map (item) -> { id: item.symbol, text: "#{item.symbol} - #{item.name}" }
        results: results
    minimumInputLength: 2
    language:
      inputTooShort: (args) -> ""

$(document).on 'turbolinks:load turbo:load', ready
