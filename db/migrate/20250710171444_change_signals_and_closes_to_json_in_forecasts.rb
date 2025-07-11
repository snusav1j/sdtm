class ChangeSignalsAndClosesToJsonInForecasts < ActiveRecord::Migration[8.0]
  def change
    def up
      # Для PostgreSQL меняем тип на jsonb, если у тебя другая БД, поменяй на json или jsonb
      change_column :forecasts, :signals, :jsonb, using: 'signals::jsonb'
      change_column :forecasts, :closes, :jsonb, using: 'closes::jsonb'
    end
  
    def down
      change_column :forecasts, :signals, :text, using: 'signals::text'
      change_column :forecasts, :closes, :text, using: 'closes::text'
    end
  end
end
