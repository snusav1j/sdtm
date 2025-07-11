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

  # ⚙️ Диагностика
  console.log "✅ closes.length:", closes.length
  console.log "✅ expectedRange:", expectedRange
  console.log "✅ direction:", direction
  console.log "✅ macd.macdLine.length:", macd.macdLine?.length
  console.log "✅ macd.signalLine.length:", macd.signalLine?.length
  console.log "✅ rsi.length:", rsi.length
  console.log "✅ stochasticRsi.length:", stochasticRsi.length

  labels = closes.map (v, i) -> i
  forecastLabels = (closes.length + i for i in [1..5])
  allLabels = labels.concat(forecastLabels)

  ctx = chartElement.getContext('2d')

  minVal = Math.min.apply(Math, closes)
  maxVal = Math.max.apply(Math, closes)

  forecastMin = Array(closes.length).fill(null).concat(Array(5).fill(expectedRange[0]))
  forecastMax = Array(closes.length).fill(null).concat(Array(5).fill(expectedRange[1]))
  forecastAvg = Array(closes.length).fill(null).concat(Array(5).fill((expectedRange[0] + expectedRange[1]) / 2.0))

  # Заливка прогноза (только область прогноза, без линий)
  forecastFill = forecastAvg.map (val, idx) ->
    if idx >= closes.length then val else null

  # Плагин вертикальной линии
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
      ctx.setLineDash([4, 6])
      ctx.stroke()
      ctx.restore()

  new Chart ctx,
    type: 'line'
    data:
      labels: allLabels
      datasets: [
        {
          label: "Цена"
          data: closes.concat(Array(5).fill null)
          borderColor: if direction == 'Up' then 'rgb(0, 200, 0)' else 'rgb(200, 0, 0)'
          fill: false
          tension: 0.3
          yAxisID: 'y'
          pointRadius: 0
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
        }
        {
          label: "Область прогноза"
          data: forecastFill
          backgroundColor: 'rgba(0, 0, 255, 0.08)'
          fill: true
          borderWidth: 0
          pointRadius: 0
          yAxisID: 'y'
        }
        {
          label: "MACD Line"
          data: (macd.macdLine || []).concat(Array(5).fill null)
          borderColor: 'rgba(255, 99, 132, 1)'
          fill: false
          tension: 0.3
          yAxisID: 'macd'
          pointRadius: 0
        }
        {
          label: "Signal Line"
          data: (macd.signalLine || []).concat(Array(5).fill null)
          borderColor: 'rgba(255, 159, 64, 1)'
          fill: false
          tension: 0.3
          yAxisID: 'macd'
          pointRadius: 0
        }
        {
          label: "RSI"
          data: rsi.concat(Array(5).fill null)
          borderColor: 'rgba(54, 162, 235, 1)'
          fill: false
          tension: 0.3
          yAxisID: 'rsi'
          pointRadius: 0
        }
        {
          label: "Stochastic RSI"
          data: stochasticRsi.concat(Array(5).fill null)
          borderColor: 'rgba(153, 102, 255, 1)'
          fill: false
          tension: 0.3
          yAxisID: 'rsi'
          pointRadius: 0
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
