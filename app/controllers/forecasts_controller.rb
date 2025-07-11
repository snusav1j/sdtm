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
      expected_range: result[:expected_range],
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
end
