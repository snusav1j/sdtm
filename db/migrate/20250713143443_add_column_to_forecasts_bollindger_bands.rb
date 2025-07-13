class AddColumnToForecastsBollindgerBands < ActiveRecord::Migration[8.0]
  def change
    add_column :forecasts, :bollinger_bands, :json, default: { upper: [], middle: [], lower: [] }
  end
end
