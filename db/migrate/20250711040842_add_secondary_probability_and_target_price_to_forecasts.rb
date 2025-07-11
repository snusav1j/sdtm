class AddSecondaryProbabilityAndTargetPriceToForecasts < ActiveRecord::Migration[8.0]
  def change
    add_column :forecasts, :secondary_probability, :float, default: 0.0, null: false
    add_column :forecasts, :target_price, :float, default: 0.0, null: false
  end
end
