ready = ->
  chartElement = document.getElementById('priceChart')
  return unless chartElement

  parseJson = (value, fallback = []) ->
    try
      JSON.parse(value)
    catch error
      console.warn("Ошибка парсинга JSON:", error)
      fallback

  closes = parseJson(chartElement.dataset.closes, [])
  expectedRange = parseJson(chartElement.dataset.expectedrange, [0, 0])
  direction = chartElement.dataset.direction || 'Up'
  macd = parseJson(chartElement.dataset.macd, { macdLine: [], signalLine: [] })
  rsi = parseJson(chartElement.dataset.rsi, [])
  stochasticRsi = parseJson(chartElement.dataset.stochasticrsi, [])

  labels = closes.map (v, i) -> i
  forecastLabels = (closes.length + i for i in [1..5])
  allLabels = labels.concat(forecastLabels)

  ctx = chartElement.getContext('2d')

  minVal = Math.min(Math.min.apply(Math, closes), expectedRange[0]) * 0.995
  maxVal = Math.max(Math.max.apply(Math, closes), expectedRange[1]) * 1.005

  forecastMin = Array(closes.length).fill(null).concat(Array(5).fill(expectedRange[0]))
  forecastMax = Array(closes.length).fill(null).concat(Array(5).fill(expectedRange[1]))
  forecastAvg = Array(closes.length).fill(null).concat(Array(5).fill((expectedRange[0] + expectedRange[1]) / 2.0))

  datasets = [
    {
      label: "Цена"
      data: closes.concat(Array(5).fill null)
      borderColor: if direction == 'Up' then 'rgb(0, 200, 0)' else 'rgb(200, 0, 0)'
      fill: false
      tension: 0.3
      yAxisID: 'y'
      pointRadius: 0
      hidden: false
    }
    {
      label: "Прогноз — нижняя граница"
      data: forecastMin
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
      data: forecastMax
      borderColor: 'rgba(0, 0, 255, 0.08)' # линия невидимая
      backgroundColor: 'rgba(0, 0, 255, 0.08)'
      fill: '-1' # заливка до нижней границы
      pointRadius: 0
      tension: 0.3
      yAxisID: 'y'
      hidden: false
    }
    {
      label: "Прогноз — верхняя граница"
      data: forecastMax
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
      data: forecastAvg
      borderColor: 'rgba(0, 0, 255, 1)'
      borderDash: [2, 2]
      fill: false
      tension: 0.3
      yAxisID: 'y'
      pointRadius: 0
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
      hidden: false
    }
    {
      label: "Signal Line"
      data: (macd.signalLine || []).concat(Array(5).fill null)
      borderColor: 'rgba(255, 159, 64, 1)'
      fill: false
      tension: 0.3
      yAxisID: 'macd'
      pointRadius: 0
      hidden: false
    }
    {
      label: "RSI"
      data: rsi.concat(Array(5).fill null)
      borderColor: 'rgba(54, 162, 235, 1)'
      fill: false
      tension: 0.3
      yAxisID: 'rsi'
      pointRadius: 0
      hidden: false
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

  rgbaToBackground = (rgba) ->
    m = rgba.match(/rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d\.]+)\)/)
    if m
      "rgba(#{m[1]}, #{m[2]}, #{m[3]}, 0.15)"
    else
      rgba

  toggleContainer = document.createElement('div')
  toggleContainer.style.marginBottom = '10px'
  toggleContainer.classList.add('forecasts-chart-block')

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
    # btn.style.alignItems = 'center'
    btn.style.justifyContent = 'space-between'
    btn.style.gap = '6px'

    color = dataset.backgroundColor ? dataset.borderColor
    btn.style.borderColor = color

    # Текст
    label = document.createElement('span')
    label.textContent = dataset.label
    label.style.color = 'var(--main-text-color, #1b1b1b)'
    label.style.fontSize = '14px'

    # Иконка
    icon = document.createElement('span')
    icon.classList.add('material-symbols-outlined', 'g-icon')
    icon.style.color = 'var(--main-text-color, #1b1b1b)'
    icon.textContent = 'visibility_off'

    btn.appendChild(label)
    btn.appendChild(icon)

    btn.onclick = (e) ->
      idx = parseInt(e.currentTarget.dataset.index)
      ds = chart.data.datasets[idx]
      ds.hidden = !ds.hidden

      icon.textContent = if ds.hidden then 'visibility' else 'visibility_off'

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
      interaction:
        mode: 'index'
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
