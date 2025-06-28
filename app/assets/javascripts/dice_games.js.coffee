# === Глобальные переменные состояния ===
initialBetAmount = null
currentBetAmount = null
lastProcessedResult = null
inMartingale = false
autoplayInterval = null
autoplayTimeout = null

# Получаем текущий результат (win/lose) из последнего элемента
getCurrentResult = ->
  $('#win_lose_result').last().attr('data-win-lose')?.trim()

# Получаем текущий баланс пользователя
getUserBalance = ->
  parseFloat($('#user_balance').attr('data-balance'))

# Обновляем поле ставки
updateBetField = (amount) ->
  $('#bet_amount').val(amount.toFixed(2))

# Останавливаем автоигру и чистим таймеры
stopAutoplay = ->
  clearInterval(autoplayInterval) if autoplayInterval?
  clearTimeout(autoplayTimeout) if autoplayTimeout?
  autoplayInterval = null
  autoplayTimeout = null
  console.log('Автоигра остановлена')

# Логика изменения ставки в зависимости от результата и режима
handleResult = (result) ->
  console.log "Результат: #{result}, режим: #{inMartingale ? 'Мартингейл' : 'Обычный'}, ставка: #{currentBetAmount}"

  if inMartingale
    if result == 'lose'
      # Удваиваем ставку после проигрыша в режиме Мартингейла
      currentBetAmount *= 2
    else if result == 'win'
      # После выигрыша — сбрасываем ставку и выходим из Мартингейла
      currentBetAmount = initialBetAmount
      inMartingale = false
  else
    if result == 'win'
      # При обычном режиме — делим ставку на 2, минимум 0.01
      currentBetAmount = Math.max(currentBetAmount / 2, 0.01)
    else if result == 'lose'
      # После проигрыша в обычном режиме — переходим в Мартингейл, ставим удвоенную ставку
      currentBetAmount = initialBetAmount * 2
      inMartingale = true

  # Обновляем поле и кликаем по кнопке
  updateBetField(currentBetAmount)
  $('#play_button').click()
  lastProcessedResult = result

# Запуск автоигры с циклом
startAutoplay = ->
  $('#play_button').click()  # Первый клик

  autoplayInterval = setInterval ->
    try
      result = getCurrentResult()
      return unless result  # Ждем пока появится результат



      balance = getUserBalance()
      if balance < currentBetAmount
        toastr.error("Баланс #{balance} меньше ставки #{currentBetAmount}, автоигра остановлена")
        stopAutoplay()
        return

      handleResult(result)
    catch error
      console.error('Ошибка в автоигре:', error)
  , 850

# Обработчик клика по кнопке автоплей
$ ->
  $(document).on 'click', '.autoplay_bot', (e) ->
    auto_play_bet_amount = $('.dice-game-settings').attr('data-auto-play-bet-amount')

    if !auto_play_bet_amount? or auto_play_bet_amount == '0'
      toastr.warning('Выберите ставку для автоигры в настройках')
      return

    # Если автоигра уже запущена — останавливаем
    if autoplayInterval? or autoplayTimeout?
      stopAutoplay()
      return

    # Инициализация
    initialBetAmount = parseFloat(auto_play_bet_amount)
    currentBetAmount = initialBetAmount
    lastProcessedResult = null
    inMartingale = false

    updateBetField(currentBetAmount)

    autoplayTimeout = setTimeout ->
      startAutoplay()
      autoplayTimeout = null
    , 850


  $(document).on 'input', '#chance_range', (e) ->
    chance = $(e.target).val()
    $('#chance_value').text("#{chance}%")
    $('#chance_bar').css('width', "#{chance}%")


  updateChance = (val) ->
    val = Math.min(99, Math.max(1, parseInt(val)))
    $('#chance_range').val(val)
    $('#chance_input').val(val)
    $('#chance_value').text("#{val}%")
    $('#chance_bar').css('width', "#{val}%")

  $(document).on 'click','#chance_range', (e) ->
    updateChance($(e.target).val())

  $(document).on 'click','#chance_input', (e) ->
    updateChance($(e.target).val())

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

  $(document).on 'click', '.dice-game-settings', (e) ->
    $.ajax
      url: "/dice_games/dice_game_settings_modal"
      dataType: "script"
      type: "GET"

