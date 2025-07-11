document.addEventListener 'DOMContentLoaded', ->

  chartElement = document.getElementById('priceChart')
  return unless chartElement

  parseJson = (value, fallback = []) ->
    try
      JSON.parse(value)
    catch error
      console.warn("Ошибка парсинга JSON:", error)
      fallback

  closes = parseJson(chartElement.dataset.closes, [])
  expectedRange = parseJson(chartElement.dataset.expectedRange, [0, 0])
  direction = chartElement.dataset.direction || 'Up'
  macd = parseJson(chartElement.dataset.macd, { macdLine: [], signalLine: [] })
  rsi = parseJson(chartElement.dataset.rsi, [])
  stochasticRsi = parseJson(chartElement.dataset.stochasticrsi, [])

  labels = closes.map (v, i) -> i
  forecastLabels = (closes.length + i for i in [1..5])

  priceData = closes
  forecastLow = (expectedRange[0] for i in [1..5])
  forecastHigh = (expectedRange[1] for i in [1..5])

  allLabels = labels.concat(forecastLabels)

  ctx = chartElement.getContext('2d')

  minVal = Math.min.apply(Math, priceData)
  maxVal = Math.max.apply(Math, priceData)

  # Регистрируем плагин для вертикальной линии
  Chart.register
    id: 'verticalLinePlugin'
    afterDraw: (chart) ->
      return unless chart.tooltip?._active?.length
      ctx = chart.ctx
      activePoint = chart.tooltip._active[0]
      x = activePoint.element.x
      topY = chart.scales.y.top
      bottomY = chart.scales.rsi.bottom

      ctx.save()
      ctx.beginPath()
      ctx.moveTo(x, topY)
      ctx.lineTo(x, bottomY)
      ctx.lineWidth = 1
      ctx.strokeStyle = '#666'
      ctx.setLineDash([4, 6])  # пунктирная линия
      ctx.stroke()
      ctx.restore()

  new Chart ctx,
    type: 'line'
    data:
      labels: allLabels
      datasets: [
        {
          label: "Цена"
          data: priceData.concat(Array(5).fill null)
          borderColor: if direction == 'Up' then 'rgb(0, 200, 0)' else 'rgb(200, 0, 0)'
          fill: false
          tension: 0.3
          yAxisID: 'y'
        }
        {
          label: "Прогноз — нижняя граница"
          data: (Array(closes.length).fill null).concat(forecastLow)
          borderColor: 'rgba(0, 0, 255, 1)'
          borderDash: [5, 5]
          fill: false
          tension: 0.3
          yAxisID: 'y'
        }
        {
          label: "Прогноз — верхняя граница"
          data: (Array(closes.length).fill null).concat(forecastHigh)
          borderColor: 'rgba(0, 0, 255, 1)'
          borderDash: [5, 5]
          fill: false
          tension: 0.3
          yAxisID: 'y'
        }
        {
          label: "MACD Line"
          data: (macd.macdLine || []).concat(Array(5).fill null)
          borderColor: 'rgba(255, 99, 132, 1)'
          fill: false
          tension: 0.3
          yAxisID: 'macd'
        }
        {
          label: "Signal Line"
          data: (macd.signalLine || []).concat(Array(5).fill null)
          borderColor: 'rgba(255, 159, 64, 1)'
          fill: false
          tension: 0.3
          yAxisID: 'macd'
        }
        {
          label: "RSI"
          data: rsi.concat(Array(5).fill null)
          borderColor: 'rgba(54, 162, 235, 1)'
          fill: false
          tension: 0.3
          yAxisID: 'rsi'
        }
        {
          label: "Stochastic RSI"
          data: stochasticRsi.concat(Array(5).fill null)
          borderColor: 'rgba(153, 102, 255, 1)'
          fill: false
          tension: 0.3
          yAxisID: 'rsi'
        }
      ]
    options:
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
          beginAtZero: false
          min: minVal * 0.995
          max: maxVal * 1.005
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

