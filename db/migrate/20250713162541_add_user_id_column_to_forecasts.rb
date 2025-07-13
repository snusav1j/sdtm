class AddUserIdColumnToForecasts < ActiveRecord::Migration[8.0]
  def change
    add_reference :forecasts, :user, foreign_key: true, index: true
  end
end
