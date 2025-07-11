class AddIndicatorsToForsecasts < ActiveRecord::Migration[8.0]
  def change
    add_column :forecasts, :stochastic_rsi, :text
    add_column :forecasts, :macd, :text
  end
end
