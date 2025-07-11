class CreateForecasts < ActiveRecord::Migration[8.0]
  def change
    create_table :forecasts do |t|
      t.string :symbol
      t.string :timeframe
      t.text :signals
      t.text :closes

      t.timestamps
    end
  end
end
