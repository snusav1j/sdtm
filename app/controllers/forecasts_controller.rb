class ForecastsController < ApplicationController
  before_action :authenticate_user!
  require 'net/http'
  require 'json'

  def index
    @forecast = Forecast.new
    @forecasts = Forecast.where(user_id: current_user.id).all.reverse

  end
  
  def create
    symbol = params[:forecast][:symbol].to_s.upcase
    timeframe = params[:forecast][:timeframe].to_s
  
    existing_forecast = Forecast.find_by(user_id: current_user.id, symbol: symbol, timeframe: timeframe)
  
    service = CryptoTaService.new(symbol, timeframe)
    result = service.analyze
  
    if result[:closes].blank? || result[:closes].size < 10
      flash[:danger] = "Не удалось получить данные по монете #{symbol}. Попробуйте позже."
      redirect_to forecasts_path and return
    end
  
    if existing_forecast
      # Обновляем существующий прогноз
      existing_forecast.update(
        closes: result[:closes],
        opens: result[:opens] || result[:closes],
        highs: result[:highs] || [],
        lows: result[:lows] || [],
        volumes: result[:volumes] || [],
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
        stochastic_rsi: result[:stochastic_rsi],
        bollinger_bands: result[:bollinger_bands]
      )
      flash[:success] = "Прогноз для монеты #{symbol} обновлён."
      redirect_to forecast_path(existing_forecast) and return
    else
      # Создаём новый прогноз
      @forecast = Forecast.create!(
        user_id: current_user.id,
        symbol: symbol,
        timeframe: timeframe,
        closes: result[:closes],
        opens: result[:opens] || result[:closes],
        highs: result[:highs] || [],
        lows: result[:lows] || [],
        volumes: result[:volumes] || [],
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
        stochastic_rsi: result[:stochastic_rsi],
        bollinger_bands: result[:bollinger_bands]
      )
      redirect_to forecast_path(@forecast)
    end
  end

  def show
    @forecast = Forecast.find(params[:id])

    @closes_json = parse_json_safe(@forecast.closes, [])
    @opens_json = parse_json_safe(@forecast.opens, @closes_json)
    @highs_json = parse_json_safe(@forecast.highs, [])
    @lows_json = parse_json_safe(@forecast.lows, [])
    @volumes_json = parse_json_safe(@forecast.volumes, [])
    @expected_range_json = parse_json_safe(@forecast.expected_range, [0, 0])
    @macd_json = parse_json_safe(@forecast.macd, { 'macdLine' => [], 'signalLine' => [] })
    @rsi_json = parse_json_safe(@forecast.rsi, [])
    @stochastic_rsi_json = parse_json_safe(@forecast.stochastic_rsi, [])
    @bollinger_bands_json = parse_json_safe(@forecast.bollinger_bands, { upper: [], middle: [], lower: [] })
    @ema_json = parse_json_safe(@forecast.ema, [])
    @sma_json = parse_json_safe(@forecast.sma, [])
    opens = @opens_json
    highs = @highs_json
    lows = @lows_json
    closes = @closes_json

    @candles_json = opens.each_with_index.map do |open_price, i|
      {
        x: i,
        o: open_price,
        h: highs[i],
        l: lows[i],
        c: closes[i]
      }
    end
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
      flash[:danger] = "Не удалось обновить данные по монете #{@forecast.symbol}. Попробуйте позже."
      redirect_to forecast_path(@forecast) and return
    end

    @forecast.update(
      user_id: current_user.id,
      closes: result[:closes],
      opens: result[:opens] || result[:closes],
      highs: result[:highs] || [],
      lows: result[:lows] || [],
      volumes: result[:volumes] || [],
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
      stochastic_rsi: result[:stochastic_rsi],
      bollinger_bands: result[:bollinger_bands]
    )

    flash[:success] = "Прогноз обновлён"
    redirect_to forecast_path(@forecast)
  end

  private

  def parse_json_safe(raw, fallback)
    return fallback if raw.blank?

    if raw.is_a?(String)
      JSON.parse(raw)
    elsif raw.is_a?(Array) || raw.is_a?(Hash)
      raw
    else
      fallback
    end
  rescue JSON::ParserError, TypeError => e
    Rails.logger.warn "JSON parse error: #{e.message}, raw: #{raw.inspect}"
    fallback
  end
end
