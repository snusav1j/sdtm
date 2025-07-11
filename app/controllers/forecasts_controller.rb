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
      closes: result[:closes],            # передаем массив
      signals: result[:signals],
      direction: result[:direction].to_s,
      probability: result[:probability].to_f,
      secondary_probability: result[:secondary_probability].to_f,
      expected_range: result[:expected_range].is_a?(Array) ? result[:expected_range] : [0, 0],
      target_price: result[:target_price].to_f,
      sma: result[:sma],
      ema: result[:ema],
      rsi: result[:rsi],
      macd: result[:macd],
      stochastic_rsi: result[:stochastic_rsi]
    )

    redirect_to forecast_path(@forecast)
  end

  def show
    @forecast = Forecast.find(params[:id])

    # Уже десериализованные значения, сразу используем
    @closes_json = @forecast.closes || []
    @expected_range_json = @forecast.expected_range || [0, 0]
    @macd_json = @forecast.macd || { 'macdLine' => [], 'signalLine' => [] }
    @rsi_json = @forecast.rsi || []
    @stochastic_rsi_json = @forecast.stochastic_rsi || []
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
  
  def update
    @forecast = Forecast.find(params[:id])
  
    service = CryptoTaService.new(@forecast.symbol, @forecast.timeframe)
    result = service.analyze
  
    if result[:closes].blank? || result[:closes].size < 10
      flash[:alert] = "Не удалось обновить данные по монете #{@forecast.symbol}. Попробуйте позже."
      redirect_to forecast_path(@forecast) and return
    end
  
    # Обновляем атрибуты прогноза (с сериализацией как в create)
    @forecast.update(
      closes: result[:closes],
      signals: result[:signals],
      direction: result[:direction].to_s,
      probability: result[:probability].to_f,
      secondary_probability: result[:secondary_probability].to_f,
      expected_range: result[:expected_range].is_a?(Array) ? result[:expected_range] : [0, 0],
      target_price: result[:target_price].to_f,
      sma: result[:sma],
      ema: result[:ema],
      rsi: result[:rsi],
      macd: result[:macd],
      stochastic_rsi: result[:stochastic_rsi]
    )
  
    flash[:notice] = "Прогноз обновлён"
    redirect_to forecast_path(@forecast)
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
    obj = if value.nil?
      default
    elsif value.is_a?(String)
      begin
        JSON.parse(value)
      rescue JSON::ParserError
        default
      end
    else
      value
    end
    obj.to_json
  end
end
