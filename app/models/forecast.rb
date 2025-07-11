class Forecast < ApplicationRecord
  validates :symbol, :timeframe, presence: true

  def signals
    JSON.parse(read_attribute(:signals) || '[]')
  end

  def signals=(value)
    write_attribute(:signals, value.to_json)
  end

  def closes
    val = read_attribute(:closes)
    return [] if val.nil? || val.empty?
  
    # Если уже массив — вернуть
    return val if val.is_a?(Array)
  
    # Если строка, попробуем распарсить
    parsed = JSON.parse(val)
    # Защитимся — если после парсинга массив — вернуть, иначе пустой
    parsed.is_a?(Array) ? parsed : []
  rescue JSON::ParserError
    []
  end

  # Простая скользящая средняя
  def sma(period = 14)
    return [] if closes.size < period

    closes.each_cons(period).map { |slice| (slice.sum / period.to_f).round(4) }
  end

  # Экспоненциальная скользящая средняя
  def ema(period = 14)
    return [] if closes.size < period

    k = 2.0 / (period + 1)
    ema_values = []
    closes.each_with_index do |close, i|
      if i == period - 1
        sma = closes[0...period].sum / period.to_f
        ema_values << sma
      elsif i >= period
        ema_prev = ema_values.last
        ema_values << ((close - ema_prev) * k + ema_prev)
      end
    end
    ema_values.map { |v| v.round(4) }
  end

  # RSI (Relative Strength Index)
  def rsi(period = 14)
    return [] if closes.size <= period

    gains = []
    losses = []

    closes.each_cons(2) do |prev, curr|
      change = curr - prev
      gains << (change > 0 ? change : 0)
      losses << (change < 0 ? change.abs : 0)
    end

    rsi_values = []
    avg_gain = gains[0...period].sum / period.to_f
    avg_loss = losses[0...period].sum / period.to_f

    rsi_values << 100 - (100 / (1 + avg_gain / (avg_loss.zero? ? 1 : avg_loss)))

    gains[period..-1].each_with_index do |gain, i|
      loss = losses[period + i]
      avg_gain = (avg_gain * (period - 1) + gain) / period
      avg_loss = (avg_loss * (period - 1) + loss) / period
      rs = avg_gain / (avg_loss.zero? ? 1 : avg_loss)
      rsi = 100 - (100 / (1 + rs))
      rsi_values << rsi.round(4)
    end

    Array.new(period, nil) + rsi_values
  end

  # MACD (Moving Average Convergence Divergence)
  def macd(short_period = 12, long_period = 26, signal_period = 9)
    return { macdLine: [], signalLine: [] } if closes.size < long_period + signal_period

    ema_short = ema(short_period)
    ema_long = ema(long_period)
    macd_line = []

    offset = long_period - short_period
    length = [ema_short.length, ema_long.length].min

    length.times do |i|
      macd_line << (ema_short[i + offset] - ema_long[i])
    end

    signal_line = []
    k = 2.0 / (signal_period + 1)
    macd_line.each_with_index do |val, i|
      if i == signal_period - 1
        sma = macd_line[0...signal_period].sum / signal_period.to_f
        signal_line << sma
      elsif i >= signal_period
        prev = signal_line.last
        signal_line << ((val - prev) * k + prev)
      else
        signal_line << nil
      end
    end

    {
      macdLine: macd_line.map { |v| v.round(4) },
      signalLine: signal_line.map { |v| v&.round(4) }
    }
  end

  # Stochastic RSI
  def stochastic_rsi(k_period = 14, d_period = 3)
    rsi_values = rsi(k_period)
    return [] if rsi_values.compact.size < k_period

    stoch_rsi = []

    rsi_values.length.times do |i|
      if i < k_period - 1 || rsi_values[i].nil?
        stoch_rsi << nil
      else
        window = rsi_values[(i - k_period + 1)..i].compact
        min_rsi = window.min
        max_rsi = window.max
        val = max_rsi - min_rsi == 0 ? 0 : (rsi_values[i] - min_rsi) / (max_rsi - min_rsi)
        stoch_rsi << val.round(4)
      end
    end

    d_values = []
    stoch_rsi.each_with_index do |val, i|
      if i < d_period - 1 || val.nil?
        d_values << nil
      else
        window = stoch_rsi[(i - d_period + 1)..i].compact
        d_values << (window.sum / window.size).round(4)
      end
    end

    d_values
  end
end
