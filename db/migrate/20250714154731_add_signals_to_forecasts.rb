class AddSignalsToForecasts < ActiveRecord::Migration[8.0]
  def change
    add_column :forecasts, :signal, :string, default: 'hold', null: false
    add_index :forecasts, :signal

    add_column :forecasts, :risk_reward_ratio, :float, null: false, default: 0.0
    add_column :forecasts, :stop_loss_level, :float, null: false, default: 0.0
    add_column :forecasts, :take_profit_level, :float, null: false, default: 0.0
    add_column :forecasts, :position_size, :float, null: false, default: 0.0
  end
end
