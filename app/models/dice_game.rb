class DiceGame < ApplicationRecord
  belongs_to :user

  validates :bet_amount, presence: true, numericality: { greater_than: 0 }
  validates :chance, presence: true, inclusion: { in: 1..99 }

  RESULT_WIN = 'win'
  RESULT_LOSE = 'lose'
  RESULT_DRAW = 'draw'

  def self.get_history(user=nil, show=25)
    if user
      self.where(user_id: user.id).last(show).reverse
    else
      self.last(25).reverse
    end
  end

  def self.play!(chance, user, bet_amount)
    return unless user.valid_balance_for_dice?(bet_amount)
  
    total_balance = user.balance
    roll_result = rand(1..100)
    multiplier = 100 / chance
  
    if roll_result <= chance
      game_result = RESULT_WIN
      win_amount = (bet_amount * multiplier) - bet_amount
      total_balance += win_amount
    elsif roll_result >= chance
      game_result = RESULT_LOSE
      lose_amount = bet_amount
      total_balance -= bet_amount
    else
      game_result = RESULT_DRAW
    end
  
    game = self.create_game_result(user, chance, bet_amount, win_amount || 0, lose_amount || 0, roll_result, game_result)
    user.change_balance_by_dice(total_balance)
    game
  end

  def self.create_game_result(user=nil, chance=nil, bet_amount=nil, win_amount=nil, lose_amount=nil, roll_result=nil, game_result=nil)
    self.create(user_id: user.id, chance: chance, 
      bet_amount: bet_amount, win_amount: win_amount, 
      lose_amount: lose_amount, roll_result: roll_result, 
      game_result: game_result)
  end

  def win?
    self.game_result == RESULT_WIN
  end
  
  def lose?
    self.game_result == RESULT_LOSE
  end
  
  def draw?
    self.game_result == RESULT_DRAW
  end

end
