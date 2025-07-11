class AddOpensToForecasts < ActiveRecord::Migration[8.0]
  def change
    add_column :forecasts, :opens, :text
  end
end
