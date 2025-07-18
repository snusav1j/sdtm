# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_14_154731) do
  create_table "dice_game_settings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.float "auto_play_bet_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_dice_game_settings_on_user_id"
  end

  create_table "dice_games", force: :cascade do |t|
    t.integer "user_id", null: false
    t.float "chance"
    t.float "bet_amount"
    t.float "win_amount"
    t.float "lose_amount"
    t.integer "roll_result"
    t.string "game_result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "auto_play_bet_amount"
    t.index ["user_id"], name: "index_dice_games_on_user_id"
  end

  create_table "forecasts", force: :cascade do |t|
    t.string "symbol"
    t.string "timeframe"
    t.text "signals"
    t.text "closes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "direction"
    t.float "probability"
    t.json "expected_range", default: []
    t.json "highs", default: []
    t.json "lows", default: []
    t.json "volumes", default: []
    t.text "sma"
    t.text "ema"
    t.text "rsi"
    t.text "stochastic_rsi"
    t.text "macd"
    t.float "secondary_probability", default: 0.0, null: false
    t.float "target_price", default: 0.0, null: false
    t.text "opens"
    t.json "bollinger_bands", default: {"upper"=>[], "middle"=>[], "lower"=>[]}
    t.integer "user_id"
    t.string "signal", default: "hold", null: false
    t.float "risk_reward_ratio", default: 0.0, null: false
    t.float "stop_loss_level", default: 0.0, null: false
    t.float "take_profit_level", default: 0.0, null: false
    t.float "position_size", default: 0.0, null: false
    t.index ["signal"], name: "index_forecasts_on_signal"
    t.index ["symbol", "timeframe"], name: "index_forecasts_on_symbol_and_timeframe"
    t.index ["user_id"], name: "index_forecasts_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "recipient_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.string "firstname"
    t.string "lastname"
    t.float "balance", default: 0.0, null: false
    t.string "image_name"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "dice_game_settings", "users"
  add_foreign_key "dice_games", "users"
  add_foreign_key "forecasts", "users"
end
