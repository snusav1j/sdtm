ready = ->

  # select2
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

  # chart
  chartElement = document.getElementById('priceChart')
  return unless chartElement

  parseJson = (value, fallback = []) ->
    try
      JSON.parse(value)
    catch error
      console.warn("Ошибка парсинга JSON:", value)
      fallback

  closes = parseJson(chartElement.dataset.closes, [])
  volumes = parseJson(chartElement.dataset.volumes, [])
  expectedRange = parseJson(chartElement.dataset.expectedrange, [0, 0])
  direction = chartElement.dataset.direction || 'Up'
  macd = parseJson(chartElement.dataset.macd, { macdLine: [], signalLine: [] })
  rsi = parseJson(chartElement.dataset.rsi, [])
  stochasticRsi = parseJson(chartElement.dataset.stochasticrsi, [])
  bollingerBands = parseJson(chartElement.dataset.bollingerbands, { upper: [], middle: [], lower: [] })
  sma = parseJson(chartElement.dataset.sma, [])
  ema = parseJson(chartElement.dataset.ema, [])
  candleData = parseJson(chartElement.dataset.candles, [])  # массив объектов {o,h,l,c}

  labels = closes.map (v, i) -> i
  forecastLabels = (closes.length + i for i in [1..5])
  allLabels = labels.concat(forecastLabels)

  ctx = chartElement.getContext('2d')

  minVal = Math.min(Math.min.apply(Math, closes), expectedRange[0]) * 0.995
  maxVal = Math.max(Math.max.apply(Math, closes), expectedRange[1]) * 1.005

  datasets = [
    {
      label: "Цена (свечи)"
      data: candleData
      type: 'candlestick'
      yAxisID: 'y'
      borderColor: if direction == 'Up' then 'rgb(0, 200, 0)' else 'rgb(200, 0, 0)'
      backgroundColor: 'rgba(0, 200, 0, 0.5)'
      hidden: false
    }
    {
      label: "Цена (линия)"
      data: closes.concat(Array(5).fill null)
      borderColor: 'rgb(0, 150, 0)'
      fill: false
      tension: 0.3
      yAxisID: 'y'
      pointRadius: 0
      hidden: true
    }
    {
      label: "SMA"
      data: sma.concat(Array(5).fill null)
      borderColor: 'rgba(255, 140, 0, 1)'
      fill: false
      tension: 0.3
      yAxisID: 'y'
      pointRadius: 0
      hidden: true
    }
    {
      label: "EMA"
      data: ema.concat(Array(5).fill null)
      borderColor: 'rgba(255, 215, 0, 1)'
      fill: false
      tension: 0.3
      yAxisID: 'y'
      pointRadius: 0
      hidden: true
    }
    {
      label: "Bollinger Upper"
      data: bollingerBands.upper.concat(Array(5).fill null)
      borderColor: 'rgba(0, 0, 200, 0.6)'
      fill: false
      tension: 0.3
      yAxisID: 'y'
      pointRadius: 0
      hidden: false
      tooltip: { enabled: false }
    }
    {
      label: "Bollinger Middle"
      data: bollingerBands.middle.concat(Array(5).fill null)
      borderColor: 'rgba(0, 0, 150, 1)'
      fill: false
      tension: 0.3
      yAxisID: 'y'
      pointRadius: 0
      hidden: false
      tooltip: { enabled: false }
    }
    {
      label: "Bollinger Lower"
      data: bollingerBands.lower.concat(Array(5).fill null)
      borderColor: 'rgba(0, 0, 200, 0.6)'
      fill: false
      tension: 0.3
      yAxisID: 'y'
      pointRadius: 0
      hidden: false
      tooltip: { enabled: false }
    }
    {
      label: "Прогноз — нижняя граница"
      data: Array(closes.length).fill(null).concat(Array(5).fill(expectedRange[0]))
      borderColor: 'rgba(0, 0, 255, 0.6)'
      borderDash: [4, 4]
      fill: false
      tension: 0.3
      yAxisID: 'y'
      pointRadius: 0
      hidden: false
    }
    {
      label: "Область прогноза"
      data: Array(closes.length).fill(null).concat(Array(5).fill(expectedRange[1]))
      borderColor: 'rgba(0, 0, 255, 0.08)'
      backgroundColor: 'rgba(0, 0, 255, 0.08)'
      fill: '-1'
      pointRadius: 0
      tension: 0.3
      yAxisID: 'y'
      hidden: false
    }
    {
      label: "Прогноз — верхняя граница"
      data: Array(closes.length).fill(null).concat(Array(5).fill(expectedRange[1]))
      borderColor: 'rgba(0, 0, 255, 0.6)'
      borderDash: [4, 4]
      fill: false
      tension: 0.3
      yAxisID: 'y'
      pointRadius: 0
      hidden: false
    }
    {
      label: "Средняя цель"
      data: Array(closes.length).fill(null).concat(Array(5).fill((expectedRange[0] + expectedRange[1]) / 2.0))
      borderColor: 'rgba(0, 0, 255, 1)'
      borderDash: [2, 2]
      fill: false
      tension: 0.3
      yAxisID: 'y'
      pointRadius: 0
      hidden: false
    }
    {
      label: "Объёмы"
      data: volumes.concat(Array(5).fill null)
      type: 'bar'
      yAxisID: 'volume'
      backgroundColor: 'rgba(128, 128, 128, 0.4)'
      hidden: false
    }
    {
      label: "MACD Line"
      data: (macd.macdLine || []).concat(Array(5).fill null)
      borderColor: 'rgba(255, 99, 132, 1)'
      fill: false
      tension: 0.3
      yAxisID: 'macd'
      pointRadius: 0
      hidden: true
    }
    {
      label: "Signal Line"
      data: (macd.signalLine || []).concat(Array(5).fill null)
      borderColor: 'rgba(255, 159, 64, 1)'
      fill: false
      tension: 0.3
      yAxisID: 'macd'
      pointRadius: 0
      hidden: true
    }
    {
      label: "RSI"
      data: rsi.concat(Array(5).fill null)
      borderColor: 'rgba(54, 162, 235, 1)'
      fill: false
      tension: 0.3
      yAxisID: 'rsi'
      pointRadius: 0
      hidden: true
    }
    {
      label: "Stochastic RSI"
      data: stochasticRsi.concat(Array(5).fill null)
      borderColor: 'rgba(153, 102, 255, 1)'
      fill: false
      tension: 0.3
      yAxisID: 'rsi'
      pointRadius: 0
      hidden: false
    }
  ]

  toggleContainer = document.createElement('div')
  toggleContainer.style.marginBottom = '10px'
  toggleContainer.classList.add('forecasts-chart-block')

  chart = null

  toggleDatasetVisibility = (idx, btn, icon, label) ->
    ds = chart.data.datasets[idx]
    ds.hidden = !ds.hidden
    if ds.hidden
      icon.textContent = 'visibility'
      label.textContent = 'Показать ' + ds.label
    else
      icon.textContent = 'visibility_off'
      label.textContent = 'Скрыть ' + ds.label

    areaIndex = chart.data.datasets.findIndex (d) -> d.label == "Область прогноза"
    lowerIndex = chart.data.datasets.findIndex (d) -> d.label == "Прогноз — нижняя граница"
    upperIndex = chart.data.datasets.findIndex (d) -> d.label == "Прогноз — верхняя граница"

    if idx == lowerIndex
      if ds.hidden
        chart.data.datasets[areaIndex].hidden = false
        toggleContainer.querySelectorAll('button').forEach (b) ->
          if parseInt(b.dataset.index) == areaIndex
            b.querySelector('span.material-symbols-outlined').textContent = 'visibility_off'
    else if idx == upperIndex
      chart.data.datasets[areaIndex].hidden = ds.hidden
      toggleContainer.querySelectorAll('button').forEach (b) ->
        if parseInt(b.dataset.index) == areaIndex
          b.querySelector('span.material-symbols-outlined').textContent = if ds.hidden then 'visibility' else 'visibility_off'

    chart.update({duration: 500, lazy: false})

  datasets.forEach (dataset, index) ->

    btn = document.createElement('button')
    btn.dataset.index = index
    btn.classList.add('gradient-hover')
    btn.style.marginRight = '6px'
    btn.style.marginBottom = '6px'
    btn.style.padding = '4px 10px'
    btn.style.cursor = 'pointer'
    btn.style.borderRadius = '4px'
    btn.style.backgroundColor = 'transparent'
    btn.style.borderWidth = '2px'
    btn.style.borderStyle = 'solid'
    btn.style.display = 'flex'
    btn.style.justifyContent = 'space-between'
    btn.style.gap = '6px'

    color = dataset.backgroundColor ? dataset.borderColor
    btn.style.borderColor = color

    label = document.createElement('span')
    label.style.color = 'var(--main-text-color, #1b1b1b)'
    label.style.fontSize = '14px'

    icon = document.createElement('span')
    icon.classList.add('material-symbols-outlined', 'g-icon')
    icon.style.color = 'var(--main-text-color, #1b1b1b)'

    if dataset.hidden
      icon.textContent = 'visibility'
      label.textContent = 'Показать ' + dataset.label
    else
      icon.textContent = 'visibility_off'
      label.textContent = 'Скрыть ' + dataset.label

    btn.appendChild(label)
    btn.appendChild(icon)

    btn.onclick = (e) -> toggleDatasetVisibility(index, btn, icon, label)

    toggleContainer.appendChild(btn)

  chartElement.parentNode.insertBefore(toggleContainer, chartElement)

  chart = new Chart ctx,
    type: 'line'
    data:
      labels: allLabels
      datasets: datasets
    options:
      animation:
        duration: 200
      plugins:
        legend:
          display: false
        tooltip:
          mode: 'index'
          intersect: false
        crosshair:
          line:
            color: 'rgba(0,0,0,0.3)'
            width: 1
          sync: false
          zoom: false
          snap: false
      interaction:
        mode: 'nearest'
        axis: 'x'
        intersect: false
      stacked: false
      scales:
        y:
          type: 'linear'
          display: true
          position: 'left'
          title:
            display: true
            text: 'Цена'
          min: minVal
          max: maxVal
        volume:
          type: 'linear'
          display: true
          position: 'right'
          title:
            display: true
            text: 'Объёмы'
          grid:
            drawOnChartArea: false
          min: 0
          max: Math.max.apply(null, volumes) * 18
          ticks:
            maxTicksLimit: 4
        macd:
          type: 'linear'
          display: true
          position: 'right'
          title:
            display: true
            text: 'MACD'
          grid:
            drawOnChartArea: false
        rsi:
          type: 'linear'
          display: true
          position: 'right'
          title:
            display: true
            text: 'RSI / Stoch RSI'
          min: 0
          max: 100
          grid:
            drawOnChartArea: false

$(document).on 'turbolinks:load turbo:load', ready
