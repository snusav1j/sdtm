class CryptoTaService
  def initialize(symbol, timeframe = '5m')
    @symbol = symbol
    @timeframe = timeframe
  end

  def fetch_data
    url = URI("https://api.binance.com/api/v3/klines?symbol=#{@symbol}&interval=#{@timeframe}&limit=100")
    response = Net::HTTP.get(url)
    JSON.parse(response).map { |entry| entry[4].to_f }
  rescue StandardError => e
    Rails.logger.warn "Failed to fetch data: #{e.message}"
    []
  end
  

  def volatility(data, period = 14)
    return 0 if data.size < period
    slice = data.last(period)
    mean = slice.sum / period.to_f
    variance = slice.map { |x| (x - mean)**2 }.sum / period.to_f
    Math.sqrt(variance)
  end

  def sma(data, period = 14)
    return [] if data.size < period
    result = []
    (period - 1).upto(data.size - 1) do |i|
      window = data[(i - period + 1)..i]
      result << (window.sum / period.to_f).round(4)
    end
    Array.new(period - 1, nil) + result
  end

  def ema(data, period = 14)
    return [] if data.size < period
    k = 2.0 / (period + 1)
    ema_values = []
    sma_first = data[0, period].sum / period.to_f
    ema_values[period - 1] = sma_first
    (period...data.size).each do |i|
      ema_values[i] = (data[i] * k + ema_values[i - 1] * (1 - k)).round(4)
    end
    Array.new(period - 1, nil) + ema_values[(period - 1)..-1]
  end

  def rsi(data, period = 14)
    return [] if data.size < period + 1
    gains = []
    losses = []
    data.each_cons(2) do |prev, curr|
      change = curr - prev
      gains << (change > 0 ? change : 0)
      losses << (change < 0 ? change.abs : 0)
    end

    avg_gain = gains[0, period].sum / period.to_f
    avg_loss = losses[0, period].sum / period.to_f

    rsi_values = Array.new(period, nil)

    gains[period..-1].each_with_index do |gain, idx|
      loss = losses[period + idx]
      avg_gain = (avg_gain * (period - 1) + gain) / period
      avg_loss = (avg_loss * (period - 1) + loss) / period

      rs = avg_loss.zero? ? 100 : avg_gain / avg_loss
      rsi = 100 - (100 / (1 + rs))
      rsi_values << rsi.round(2)
    end

    rsi_values
  end

  def macd(data, fast_period = 12, slow_period = 26, signal_period = 9)
    return { macdLine: [], signalLine: [] } if data.size < slow_period + signal_period

    ema_fast = ema(data, fast_period)
    ema_slow = ema(data, slow_period)
    macd_line = []

    ema_fast.zip(ema_slow).each do |fast, slow|
      if fast && slow
        macd_line << (fast - slow).round(4)
      else
        macd_line << nil
      end
    end

    valid_macd = macd_line.compact
    signal_line = ema(valid_macd, signal_period)
    signal_line = Array.new(macd_line.size - signal_line.size, nil) + signal_line

    { macdLine: macd_line, signalLine: signal_line }
  end

  def stochastic_rsi(data, period = 14)
    rsi_values = rsi(data, period)
    return [] if rsi_values.empty?

    min_rsi = rsi_values.compact.min
    max_rsi = rsi_values.compact.max

    rsi_values.map do |val|
      if val.nil? || max_rsi == min_rsi
        nil
      else
        (((val - min_rsi) / (max_rsi - min_rsi)) * 100).round(2)
      end
    end
  end

  def analyze
    closes = fetch_data
    return {} if closes.blank?

    signals = []

    sma_values = sma(closes)
    ema_values = ema(closes)
    rsi_values = rsi(closes)
    macd_values = macd(closes)
    stochastic_rsi_values = stochastic_rsi(closes)

    last_rsi = rsi_values.compact.last || 50
    last_stoch = (stochastic_rsi_values.compact.last || 50) / 100.0

    signals << "Buy (RSI)" if last_rsi < 30
    signals << "Sell (RSI)" if last_rsi > 70

    direction = if sma_values.compact.size >= 2
                  sma_values.compact[-1] > sma_values.compact[-2] ? "Up" : "Down"
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
      ema: ema_values,
      rsi: rsi_values,
      macd: macd_values,
      stochastic_rsi: stochastic_rsi_values
    }
  end
end