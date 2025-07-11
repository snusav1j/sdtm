class ForecastsController < ApplicationController
  require 'net/http'
  require 'json'

  def index
    @forecast = Forecast.new
    @forecasts = Forecast.all
  end

  def create
    symbol = params[:forecast][:symbol].to_s.upcase
    timeframe = params[:forecast][:timeframe].to_s

    service = CryptoTaService.new(symbol, timeframe)
    result = service.analyze

    if result[:closes].blank? || result[:closes].size < 10
      flash[:alert] = "Не удалось получить данные по монете #{symbol}. Попробуйте позже."
      redirect_to forecasts_path and return
    end

    @forecast = Forecast.create!(
      symbol: symbol,
      timeframe: timeframe,
      closes: safe_to_json(result[:closes]),
      signals: safe_to_json(result[:signals]),
      direction: result[:direction].to_s,
      probability: result[:probability].to_f,
      secondary_probability: result[:secondary_probability].to_f,
      expected_range: result[:expected_range].is_a?(Array) ? result[:expected_range] : [0, 0],
      target_price: result[:target_price].to_f,
      sma: safe_to_json(result[:sma]),
      ema: safe_to_json(result[:ema]),
      rsi: safe_to_json(result[:rsi]),
      macd: safe_to_json(result[:macd], default: { macdLine: [], signalLine: [] }),
      stochastic_rsi: safe_to_json(result[:stochastic_rsi])
    )

    redirect_to forecast_path(@forecast)
  end

  def show
    @forecast = Forecast.find(params[:id])

    @closes_json = parse_json_safe(@forecast.closes.presence || '[]', [])
    @expected_range_json = @forecast.expected_range.presence || [0, 0]
    @macd_json = parse_json_safe(@forecast.macd.presence || '{}', { 'macdLine' => [], 'signalLine' => [] })
    @rsi_json = parse_json_safe(@forecast.rsi.presence || '[]', [])
    @stochastic_rsi_json = parse_json_safe(@forecast.stochastic_rsi.presence || '[]', [])
  end

  def coins_search
    query = params[:q].to_s.upcase
    return render json: [] if query.blank?

    url = URI("https://api.binance.com/api/v3/exchangeInfo")
    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    coins = data['symbols'].select do |s|
      s['symbol'].include?(query) && s['status'] == 'TRADING'
    end

    render json: coins.map { |c| { symbol: c['symbol'], name: c['baseAsset'] } }
  end

  private

  def parse_json_safe(raw, fallback)
    return fallback if raw.blank?

    JSON.parse(raw)
  rescue JSON::ParserError, TypeError => e
    Rails.logger.warn "JSON parse error: #{e.message}, raw: #{raw.inspect}"
    fallback
  end

  def safe_to_json(value, default: [])
    if value.nil?
      default.to_json
    elsif value.is_a?(String)
      # Проверим, можно ли распарсить и вернуть как есть
      begin
        JSON.parse(value)
        value
      rescue JSON::ParserError
        default.to_json
      end
    else
      value.to_json
    end
  end
end
