$ ->
  $(document).on 'input', '#chance_range', (e) ->
    chance = $(e.target).val()
    
    # Обновляем текст рядом с ползунком
    $('#chance_value').text("#{chance}%")
    
    # Меняем ширину зеленого бара в #result_container
    $('#chance_bar').css('width', "#{chance}%")


  updateChance = (val) ->
    val = Math.min(99, Math.max(1, parseInt(val)))  # гарантируем диапазон
    $('#chance_range').val(val)
    $('#chance_input').val(val)
    $('#chance_value').text("#{val}%")
    $('#chance_bar').css('width', "#{val}%")

  # Слайдер
  $(document).on 'click','#chance_range', (e) ->
    updateChance($(e.target).val())

  # Ручной ввод
  $(document).on 'click','#chance_input', (e) ->
    updateChance($(e.target).val())

  # Быстрые кнопки
  $(document).on 'click','.chance-preset', (e) ->
    val = $(e.currentTarget).data('chance')
    updateChance(val)
    
  $(document).on 'click','#all_in_button', (e) ->
    balance = parseFloat($('#user_balance').attr('data-balance')) || 0
    truncated = Math.floor(balance * 100) / 100
    $('#bet_amount').val(truncated.toFixed(2))

  # $('#all_in_button').on 'click', ->
  #   balance = parseFloat($('#user_balance').text()) || 0
  #   $('#bet_amount').val(balance.toFixed(2))

  $(document).on 'click', '.bet-action', (e) ->
    action = $(e.currentTarget).data('action')
    $input = $('#bet_amount')
    value = parseFloat($input.val()) || 0

    switch action
      when 'half'
        value = value / 2
      when 'one_point_five'
        value = value / 1.5
      when 'double'
        value = value * 2
      when 'point_one_five'
        value = value * 1.5

    $input.val(value.toFixed(2))

  $(document).on 'click', '#get_last_bet_amount', (e) ->
    last_bet = parseFloat($('.last-bet-amount').first().attr('data-last-bet-amount'))
    $('input#user_balance').val(last_bet.toFixed(1))