class AddIndexToForecastsSymbolTimeframe < ActiveRecord::Migration[8.0]
  def change
    add_index :forecasts, [:symbol, :timeframe]
  end
end
