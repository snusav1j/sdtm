class AddIndicatorsToForecasts < ActiveRecord::Migration[8.0]
  def change
    add_column :forecasts, :sma, :text
    add_column :forecasts, :ema, :text
    add_column :forecasts, :rsi, :text
  end
end
