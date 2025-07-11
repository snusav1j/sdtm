class CryptoTaService
  def initialize(symbol, timeframe = '5m')
    @symbol = symbol
    @timeframe = timeframe
  end

  def fetch_data
    url = URI("https://api.binance.com/api/v3/klines?symbol=#{@symbol}&interval=#{@timeframe}&limit=100")
    response = Net::HTTP.get(url)
    JSON.parse(response).map { |entry| entry[4].to_f }
  end

  def volatility(data, period = 14)
    return 0 if data.size < period
    slice = data.last(period)
    mean = slice.sum / period.to_f
    variance = slice.map { |x| (x - mean)**2 }.sum / period.to_f
    Math.sqrt(variance)
  end


  def analyze
    closes = fetch_data
    signals = []

    forecast = Forecast.new(closes: closes.to_json)

    rsi_values = forecast.rsi
    stochastic_rsi_values = forecast.stochastic_rsi

    last_rsi = rsi_values.compact.last || 50
    last_stoch = stochastic_rsi_values.compact.last || 0.5

    # Сигналы RSI
    signals << "Buy (RSI)" if last_rsi < 30
    signals << "Sell (RSI)" if last_rsi > 70

    sma_values = forecast.sma
    direction = if sma_values.size >= 2
                  sma_values[-1] > sma_values[-2] ? "Up" : "Down"
                else
                  "Up"
                end
    signals << "Trend: #{direction}"

    vol = volatility(closes, 14)

    if closes.size >= 15
      recent_changes = closes.each_cons(2).map { |prev, curr| (curr - prev).abs }
      avg_change = recent_changes.last(14).sum / 14.0
      probability = ((avg_change / (vol.zero? ? 1 : vol)) * 100).round(2)
    else
      probability = 0.0
    end

    # Расчёт дополнительной вероятности коррекции (secondary_probability)
    avg_oscillator = (last_rsi + last_stoch * 100) / 2.0

    correction_prob = if avg_oscillator >= 50
                        ((avg_oscillator - 50) / 50.0 * 100).round(2)
                      else
                        ((50 - avg_oscillator) / 50.0 * 100).round(2)
                      end

    last_price = closes.last || 0
    delta = vol * 2

    expected_range = if direction == "Up"
                       [(last_price).round(4), (last_price + delta).round(4)]
                     else
                       [(last_price - delta).round(4), (last_price).round(4)]
                     end

    target_price = ((expected_range[0] + expected_range[1]) / 2.0).round(4)

    {
      closes: closes,
      signals: signals,
      direction: direction,
      probability: probability,
      secondary_probability: correction_prob,
      expected_range: expected_range,
      target_price: target_price,
      sma: sma_values,
      ema: forecast.ema,
      rsi: rsi_values,
      macd: forecast.macd,
      stochastic_rsi: stochastic_rsi_values
    }
  end
end
