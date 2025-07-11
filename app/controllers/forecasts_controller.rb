class ForecastsController < ApplicationController
  require 'net/http'
  require 'json'

  def index
    @forecast = Forecast.new
    @forecasts = Forecast.all
  end

  def create
    symbol = params[:forecast][:symbol].upcase
    timeframe = params[:forecast][:timeframe]

    service = CryptoTaService.new(symbol, timeframe)
    result = service.analyze

    @forecast = Forecast.create!(
      symbol: symbol,
      timeframe: timeframe,
      closes: result[:closes].to_json,
      signals: result[:signals].to_json,
      direction: result[:direction],
      probability: result[:probability],
      secondary_probability: result[:secondary_probability],
      expected_range: result[:expected_range],
      target_price: result[:target_price],
      sma: result[:sma].to_json,
      ema: result[:ema].to_json,
      rsi: result[:rsi].to_json,
      macd: result[:macd].to_json,
      stochastic_rsi: result[:stochastic_rsi].to_json
    )

    redirect_to forecast_path(@forecast)
  end

  def show
    @forecast = Forecast.find(params[:id])

    # Безопасный парсинг JSON здесь, чтобы не делать в HAML
    @closes_json = parse_json_safe(@forecast.closes, [])
    @expected_range_json = @forecast.expected_range.presence || [0, 0]
    @macd_json = parse_json_safe(@forecast.macd, { 'macdLine' => [], 'signalLine' => [] })
    @rsi_json = parse_json_safe(@forecast.rsi, [])
    @stochastic_rsi_json = parse_json_safe(@forecast.stochastic_rsi, [])
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
  rescue JSON::ParserError, TypeError
    fallback
  end
end
