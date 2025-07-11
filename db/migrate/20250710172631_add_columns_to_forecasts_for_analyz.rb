class AddColumnsToForecastsForAnalyz < ActiveRecord::Migration[8.0]
  def change
    add_column :forecasts, :direction, :string
    add_column :forecasts, :probability, :float
    add_column :forecasts, :expected_range, :jsonb, default: []
    add_column :forecasts, :highs, :jsonb, default: []
    add_column :forecasts, :lows, :jsonb, default: []
    add_column :forecasts, :volumes, :jsonb, default: []
  end
end
