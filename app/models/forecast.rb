class Forecast < ApplicationRecord
  validates :symbol, :timeframe, presence: true

  # --- signals ---
  def signals
    val = read_attribute(:signals)
    return [] if val.nil? || val.empty?

    return val if val.is_a?(Array)

    parsed = JSON.parse(val) rescue nil
    parsed.is_a?(Array) ? parsed : []
  end

  def signals=(value)
    write_attribute(:signals, value.to_json)
  end

  # --- closes ---
  def closes
    val = read_attribute(:closes)
    return [] if val.nil? || val.empty?

    return val if val.is_a?(Array)

    parsed = JSON.parse(val) rescue []
    parsed.is_a?(Array) ? parsed : []
  end

  def closes=(value)
    write_attribute(:closes, value.to_json)
  end

  # --- expected_range ---
  def expected_range
    val = read_attribute(:expected_range)
    return [0, 0] if val.nil? || val.empty?

    return val if val.is_a?(Array)

    parsed = JSON.parse(val) rescue [0, 0]
    parsed.is_a?(Array) && parsed.size == 2 ? parsed : [0, 0]
  end

  def expected_range=(value)
    write_attribute(:expected_range, value.to_json)
  end

  # --- sma ---
  def sma(period = 14)
    return [] if closes.size < period

    closes.each_cons(period).map { |slice| (slice.sum / period.to_f).round(4) }
  end

  # --- ema ---
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

  # --- rsi ---
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

  # --- macd ---
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

  # --- stochastic_rsi ---
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

  # --- secondary_probability ---
  def secondary_probability
    val = read_attribute(:secondary_probability)
    val.nil? ? 0.0 : val.to_f
  end

  def secondary_probability=(value)
    write_attribute(:secondary_probability, value.to_f)
  end

  # --- target_price ---
  def target_price
    val = read_attribute(:target_price)
    val.nil? ? 0.0 : val.to_f
  end

  def target_price=(value)
    write_attribute(:target_price, value.to_f)
  end

  def secondary_probability
    read_attribute(:secondary_probability) || 0.0
  end

  def target_price
    read_attribute(:target_price)
  end
end
