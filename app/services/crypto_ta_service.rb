require 'net/http'
require 'json'

class CryptoTaService
  def initialize(symbol, timeframe)
    @symbol = symbol
    @timeframe = timeframe
  end

  def fetch_data
    url = URI("https://api.binance.com/api/v3/klines?symbol=#{@symbol}&interval=#{@timeframe}&limit=100")
    response = Net::HTTP.get(url)
    JSON.parse(response).map { |entry| entry[4].to_f } # close prices
  end

  def analyze
    closes = fetch_data
    signals = []

    # Создаём временный объект Forecast для расчёта индикаторов вручную
    forecast = Forecast.new(closes: closes.to_json)

    # Получаем индикаторы
    rsi_values = forecast.rsi
    sma_values = forecast.sma
    ema_values = forecast.ema
    macd_data = forecast.macd
    stochastic_rsi_values = forecast.stochastic_rsi

    # Последнее значение RSI для сигналов
    last_rsi = rsi_values.compact.last || 50
    signals << "Buy (RSI)" if last_rsi < 30
    signals << "Sell (RSI)" if last_rsi > 70

    # Направление тренда по SMA
    if sma_values.size >= 2
      direction = sma_values[-1] > sma_values[-2] ? "Up" : "Down"
    else
      direction = "Up"
    end
    signals << "Trend: #{direction}"

    # Вероятность - нормированное изменение за последние 3 свечи
    if closes.size >= 4
      recent_change = (closes.last - closes[-4]) / closes[-4].to_f
      probability = (recent_change.abs * 100).round(2)
    else
      probability = 0.0
    end

    last_price = closes.last || 0
    delta = last_price * 0.03
    expected_range = if direction == "Up"
      [(last_price).round(4), (last_price + delta).round(4)]
    else
      [(last_price - delta).round(4), (last_price).round(4)]
    end

    {
      closes: closes,
      signals: signals,
      direction: direction,
      probability: probability,
      expected_range: expected_range,
      sma: sma_values,
      ema: ema_values,
      rsi: rsi_values,
      macd: macd_data,
      stochastic_rsi: stochastic_rsi_values
    }
  end
end
